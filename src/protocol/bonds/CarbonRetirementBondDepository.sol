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
    address public constant INFINITY = 0x8cE54d9625371fb2a068986d32C85De8E6e995f8;
    uint256 public constant FEE_DIVISOR = 10000;

    mapping(address => address) public poolReference;
    mapping(address => uint8) public referenceKlimaPosition;
    mapping(address => uint256) public daoFee;
    mapping(address => uint256) public maxSlippage;

    function swapToExact(address poolToken, uint256 poolAmount) external {
        require(msg.sender == INFINITY, "Caller is not Infinity");
        require(poolAmount > 0, "Cannot swap for zero tokens");

        uint256 klimaNeeded = getKlimaAmount(poolAmount, poolToken);

        transferAndBurnKlima(klimaNeeded, poolToken);
        IKlima(poolToken).safeTransfer(INFINITY, poolAmount);
    }

    function retireCarbonDefault(
        address poolToken,
        uint256 retireAmount,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage
    ) external returns (uint256 retirementIndex) {
        require(retireAmount > 0, "Cannot retire zero tokens");

        // Get the current amount of total pool tokens needed including any applicable fees
        uint256 poolNeeded = IKlimaInfinity(INFINITY).getSourceAmountDefaultRetirement(
            poolToken,
            poolToken,
            retireAmount
        );

        require(poolNeeded <= IKlima(poolToken).balanceOf(address(this)), "Not enough pool tokens to retire");

        // Get the total rate limited KLIMA needed
        uint256 klimaNeeded = getKlimaAmount(poolNeeded, poolToken);

        // Transfer and burn the KLIMA
        transferAndBurnKlima(klimaNeeded, poolToken);

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

    function transferAndBurnKlima(uint256 totalKlima, address poolToken) internal {
        // Transfer and burn the KLIMA
        uint256 feeAmount = (totalKlima * daoFee[poolToken]) / FEE_DIVISOR;

        IKlima(KLIMA).safeTransferFrom(msg.sender, DAO, feeAmount);
        IKlima(KLIMA).burnFrom(msg.sender, totalKlima - feeAmount);
    }

    function fundMarket(address poolToken, uint256 amount) external onlyOwner {
        IKlimaTreasury(TREASURY).manage(poolToken, amount);
    }

    function closeMarket(address poolToken) external onlyOwner {
        IKlima(poolToken).safeTransfer(TREASURY, IKlima(poolToken).balanceOf(address(this)));

        // Extra gas and transfers no tokens, but does trigger a reserve update within the treasury.
        IKlimaTreasury(TREASURY).manage(poolToken, 0);
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

        // If direct LP quote is 0, use quote from KI
        if (maxKlima == 0) return klimaNeeded;

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
