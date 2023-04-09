// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "oz/access/Ownable.sol";

import "../interfaces/IKlimaInfinity.sol";
import "../interfaces/IKLIMA.sol";
import "../interfaces/IUniswapV2Pair.sol";

contract CarbonRetirementBondDepository is Ownable {
    using SafeERC20 for IKlima;

    address public constant KLIMA = 0x4e78011Ce80ee02d2c3e649Fb657E45898257815;
    address public constant DAO = 0x65A5076C0BA74e5f3e069995dc3DAB9D197d995c;
    address public constant TREASURY = 0x7Dd4f0B986F032A44F913BF92c9e8b7c17D77aD7;
    address public constant INFINITY = 0xf397FBa97F60D574efBdc84093a02c899ad63aAC;
    uint256 public constant FEE_DIVISOR = 10000;

    struct Market {
        uint8 id;
        address poolToken;
        uint8 feeAmount;
        uint8 active;
    }

    constructor() {
        // BCT Pool defaults
        address bct = 0x2F800Db0fdb5223b3C3f354886d907A671414A7F;
        address bctKlima = 0x9803c7aE526049210a1725F7487AF26fE2c24614;

        poolReference[bct] = bctKlima;
        referenceKlimaPosition[bct] = 1;
        daoFee[bct] = 3000;
        maxSlippage[bct] = 200;
    }

    mapping(address => address) public poolReference;
    mapping(address => uint8) public referenceKlimaPosition;
    mapping(address => uint256) public daoFee;
    mapping(address => uint256) public maxSlippage;

    function swapPool(address poolToken, uint256 amount) external {
        require(msg.sender == INFINITY, "Caller is not Infinity");

        uint256 klimaNeeded = getKlimaAmount(amount, poolToken);
        uint256 feeAmount = (klimaNeeded * daoFee[poolToken]) / FEE_DIVISOR;

        transferAndBurnKlima(klimaNeeded, feeAmount);
        IKlima(poolToken).safeTransfer(INFINITY, amount);
    }

    function retireCarbonDefault(
        address poolToken,
        uint256 retireAmount,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage
    ) external returns (uint256 retirementIndex) {
        // Get the current amount of total pool tokens needed including any applicable fees
        uint256 poolNeeded = IKlimaInfinity(INFINITY).getSourceAmountDefaultRetirement(
            poolToken,
            poolToken,
            retireAmount
        );

        require(poolNeeded >= IKlima(poolToken).balanceOf(address(this)), "Not enough pool tokens to retire");

        // Get the total rate limited KLIMA needed
        uint256 klimaNeeded = getKlimaAmount(poolNeeded, poolToken);
        uint256 feeAmount = (klimaNeeded * daoFee[poolToken]) / FEE_DIVISOR;

        // Transfer and burn the KLIMA
        transferAndBurnKlima(klimaNeeded, feeAmount);

        IKlima(poolToken).safeIncreaseAllowance(INFINITY, poolNeeded);

        return
            IKlimaInfinity(INFINITY).retireExactCarbonDefault(
                poolToken,
                poolToken,
                poolNeeded,
                retireAmount,
                retiringEntityString,
                beneficiaryAddress,
                beneficiaryString,
                retirementMessage,
                0
            );
    }

    function transferAndBurnKlima(uint256 totalKlima, uint256 feeAmount) internal {
        // Transfer and burn the KLIMA
        IKlima(KLIMA).safeTransferFrom(msg.sender, DAO, feeAmount);
        IKlima(KLIMA).burnFrom(msg.sender, totalKlima - feeAmount);
    }

    function fundMarket(address poolToken, uint256 amount) external onlyOwner {
        // TODO: change msg.sender to TREASURY prior to mainnet deploy
        IKlima(poolToken).safeTransferFrom(msg.sender, address(this), amount);
    }

    function closeMarket(address poolToken) external onlyOwner {
        IKlima(poolToken).safeTransfer(TREASURY, IKlima(poolToken).balanceOf(address(this)));
    }

    function getMarketQuote(address poolToken, uint256 amountOut) internal view returns (uint256 currentPrice) {
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(poolReference[poolToken]).getReserves();

        currentPrice = referenceKlimaPosition[poolToken] == 0
            ? (amountOut * (reserve0)) / reserve1
            : (amountOut * (reserve1)) / reserve0;
    }

    function getKlimaAmount(uint256 poolAmount, address poolToken) public view returns (uint256 klimaNeeded) {
        uint256 maxKlima = (getMarketQuote(
            poolToken,
            (FEE_DIVISOR + maxSlippage[poolToken]) * 1e14 // Get market quote for 1 pool token + slippage percent.
        ) * poolAmount) / 1e18;

        // Check inputs through KI due to differences in DEX locations for pools
        klimaNeeded = IKlimaInfinity(INFINITY).getSourceAmountSwapOnly(KLIMA, poolToken, poolAmount);

        // Limit the KLIMA needed
        if (klimaNeeded > maxKlima) klimaNeeded = maxKlima;
    }

    function updateMaxSlippage(address poolToken, uint256 _maxSlippage) external onlyOwner {
        maxSlippage[poolToken] = _maxSlippage;
    }

    function updateDaoFee(address poolToken, uint256 _daoFee) external onlyOwner {
        daoFee[poolToken] = _daoFee;
    }

    function setPoolReference(address poolToken, address referenceToken) external onlyOwner {
        poolReference[poolToken] = referenceToken;
        referenceKlimaPosition[poolToken] = IUniswapV2Pair(referenceToken).token0() == KLIMA ? 0 : 1;
    }
}
