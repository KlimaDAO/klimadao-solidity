// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import "oz/access/Ownable2Step.sol";

import "src/protocol/interfaces/IKlimaInfinity.sol";
import {IKlima, SafeERC20} from "src/protocol/interfaces/IKLIMA.sol";
import "src/protocol/interfaces/IUniswapV2Pair.sol";

/**
 * @title CarbonRetirementBondDepository
 * @author Cujo
 * @notice A smart contract that handles the distribution of carbon in exchange for KLIMA tokens.
 * Bond depositors can only use this to retire carbon by providing KLIMA tokens.
 */

contract CarbonRetirementBondDepository is Ownable2Step {
    using SafeERC20 for IKlima;

    /// @notice Address of the KLIMA token contract.
    address public constant KLIMA = 0x4e78011Ce80ee02d2c3e649Fb657E45898257815;
    /// @notice Address of the DAO contract.
    address public constant DAO = 0x65A5076C0BA74e5f3e069995dc3DAB9D197d995c;
    /// @notice Address of the Treasury contract.
    address public constant TREASURY = 0x7Dd4f0B986F032A44F913BF92c9e8b7c17D77aD7;
    /// @notice address of the Klima Infinity contract.
    address public constant INFINITY = 0x8cE54d9625371fb2a068986d32C85De8E6e995f8;
    /// @notice Divisor used for calculating percentages.
    uint256 public constant FEE_DIVISOR = 10000;
    /// @notice Allocator contract used by policy to fund and close markets.
    address public allocatorContract;

    /// @notice Mapping that stores the KLIMA/X LP used for quoting price references.
    mapping(address => address) public poolReference;

    /// @notice Mapping that stores whether the KLIMA is token 0 or token 1 in the LP contract.
    mapping(address => uint8) public referenceKlimaPosition;

    /// @notice Mapping that stores the DAO fee charged for a specific pool token.
    mapping(address => uint256) public daoFee;

    /// @notice Mapping that stores the maximum slippage tolerated for a specific pool token.
    mapping(address => uint256) public maxSlippage;

    event AllocatorChanged(address oldAllocator, address newAllocator);
    event PoolReferenceChanged(address pool, address oldLp, address newLp);
    event ReferenceKlimaPositionChanged(address lp, uint8 oldPosition, uint8 newPosition);
    event DaoFeeChanged(address pool, uint256 oldFee, uint256 newFee);
    event PoolSlippageChanged(address pool, uint256 oldSlippage, uint256 newSlippage);

    event MarketOpened(address pool, uint256 amount);
    event MarketClosed(address pool, uint256 amount);

    event CarbonBonded(address pool, uint256 poolAmount);
    event KlimaBonded(uint256 daoFee, uint256 klimaBurned);

    /**
     * @notice Modifier to ensure that the caller is the DAO multi-sig.
     */
    modifier onlyDAO() {
        require(msg.sender == DAO, "Caller must be DAO");
        _;
    }

    /**
     * @notice Modifier to ensure that the calling function is being called by the allocator contract.
     */
    modifier onlyAllocator() {
        require(msg.sender == allocatorContract, "Only allocator can open or close bond market");
        _;
    }

    /**
     * @notice Swaps the specified amount of pool tokens for KLIMA tokens.
     * @dev Only callable by the Infinity contract.
     * @param poolToken     The pool token address.
     * @param poolAmount    The amount of pool tokens to swap.
     */
    function swapToExact(address poolToken, uint256 poolAmount) external {
        require(msg.sender == INFINITY, "Caller is not Infinity");
        require(poolAmount > 0, "Cannot swap for zero tokens");

        uint256 klimaNeeded = getKlimaAmount(poolAmount, poolToken);

        transferAndBurnKlima(klimaNeeded, poolToken);
        IKlima(poolToken).safeTransfer(INFINITY, poolAmount);

        emit CarbonBonded(poolToken, poolAmount);
    }

    /**
     * @notice Retires the specified amount of carbon for the given pool token using KI.
     * @dev Requires KLIMA spend approval for the amount returned by getKlimaAmount()
     * @param poolToken             The pool token address.
     * @param retireAmount          The amount of carbon to retire.
     * @param retiringEntityString  The string representing the retiring entity.
     * @param beneficiaryAddress    The address of the beneficiary.
     * @param beneficiaryString     The string representing the beneficiary.
     * @param retirementMessage     The message for the retirement.
     * @return retirementIndex      The index of the retirement transaction.
     */
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

        emit CarbonBonded(poolToken, poolNeeded);

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

    /**
     * @notice Retires the specified amount of carbon for the given pool token using KI.
     * Uses the provided project token for the underlying credit to retire.
     * @dev Requires KLIMA spend approval for the amount returned by getKlimaAmount()
     * @param poolToken             The pool token address.
     * @param projectToken          The project token to retire.
     * @param retireAmount          The amount of carbon to retire.
     * @param retiringEntityString  The string representing the retiring entity.
     * @param beneficiaryAddress    The address of the beneficiary.
     * @param beneficiaryString     The string representing the beneficiary.
     * @param retirementMessage     The message for the retirement.
     * @return retirementIndex      The index of the retirement transaction.
     */
    function retireCarbonSpecific(
        address poolToken,
        address projectToken,
        uint256 retireAmount,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage
    ) external returns (uint256 retirementIndex) {
        require(retireAmount > 0, "Cannot retire zero tokens");

        // Get the current amount of total pool tokens needed including any applicable fees
        uint256 poolNeeded = IKlimaInfinity(INFINITY).getSourceAmountSpecificRetirement(
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

        emit CarbonBonded(poolToken, poolNeeded);

        return
            IKlimaInfinity(INFINITY).retireExactCarbonSpecific(
                poolToken,
                poolToken,
                projectToken,
                poolNeeded,
                retireAmount,
                retiringEntityString,
                beneficiaryAddress,
                beneficiaryString,
                retirementMessage,
                0
            );
    }

    /**
     * @notice Emits event on market allocation.
     * @dev Only the allocator contract can call this function.
     * @param poolToken The address of the pool token to open the market for.
     */
    function openMarket(address poolToken) external onlyAllocator {
        emit MarketOpened(poolToken, IKlima(poolToken).balanceOf(address(this)));
    }

    /**
     * @notice Closes the market for a specified pool token by transferring all remaining pool tokens to the treasury address.
     * @dev Only the allocator contract can call this function.
     * @param poolToken The address of the pool token to close the market for.
     */
    function closeMarket(address poolToken) external onlyAllocator {
        uint256 currentBalance = IKlima(poolToken).balanceOf(address(this));
        IKlima(poolToken).safeTransfer(TREASURY, currentBalance);

        emit MarketClosed(poolToken, currentBalance);
    }

    /**
     * @notice Updates the maximum slippage percentage for a specified pool token.
     * @param poolToken The address of the pool token to update the maximum slippage percentage for.
     * @param _maxSlippage The new maximum slippage percentage.
     */
    function updateMaxSlippage(address poolToken, uint256 _maxSlippage) external onlyOwner {
        uint256 oldSlippage = maxSlippage[poolToken];
        maxSlippage[poolToken] = _maxSlippage;

        emit PoolSlippageChanged(poolToken, oldSlippage, maxSlippage[poolToken]);
    }

    /**
     * @notice Updates the DAO fee for a specified pool token.
     * @param poolToken The address of the pool token to update the DAO fee for.
     * @param _daoFee The new DAO fee.
     */
    function updateDaoFee(address poolToken, uint256 _daoFee) external onlyDAO {
        uint256 oldFee = daoFee[poolToken];
        daoFee[poolToken] = _daoFee;

        emit DaoFeeChanged(poolToken, oldFee, daoFee[poolToken]);
    }

    /**
     * @notice Sets the reference token for a given pool token. The reference token is used to determine the current price
     * of the pool token in terms of KLIMA. The position of KLIMA in the Uniswap pair for the reference token is also determined.
     * @param poolToken         The pool token for which to set the reference token.
     * @param referenceToken    The reference token for the given pool token.
     */
    function setPoolReference(address poolToken, address referenceToken) external onlyOwner {
        address oldReference = poolReference[poolToken];
        uint8 oldPosition = referenceKlimaPosition[poolToken];

        poolReference[poolToken] = referenceToken;
        referenceKlimaPosition[poolToken] = IUniswapV2Pair(referenceToken).token0() == KLIMA ? 0 : 1;

        emit PoolReferenceChanged(poolToken, oldReference, poolReference[poolToken]);
        emit ReferenceKlimaPositionChanged(poolReference[poolToken], oldPosition, referenceKlimaPosition[poolToken]);
    }

    /**
     * @notice Sets the address of the allocator contract. Only the contract owner can call this function.
     * @param allocator The address of the allocator contract to set.
     */
    function setAllocator(address allocator) external onlyDAO {
        address oldAllocator = allocatorContract;
        allocatorContract = allocator;

        emit AllocatorChanged(oldAllocator, allocatorContract);
    }

    /**
     * @notice Calculates the amount of KLIMA tokens needed to retire a specified amount of pool tokens for a pool.
     * The required amount of KLIMA tokens is calculated based on the current market price of the pool token and the amount of pool tokens to be retired.
     * If the raw amount needed from the dex exceeds slippage, than the limited amount is returned.
     * @param poolAmount    The amount of pool tokens to retire.
     * @param poolToken     The address of the pool token to retire.
     * @return klimaNeeded The amount of KLIMA tokens needed to retire the specified amount of pool tokens.
     */
    function getKlimaAmount(uint256 poolAmount, address poolToken) public view returns (uint256 klimaNeeded) {
        /// @dev On extremely small quote amounts this can result in zero
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

    /**
     * @notice Transfers and burns a specified amount of KLIMA tokens.
     * A fee is also transferred to the DAO address based on the fee divisor and the configured fee for the pool token.
     * @param totalKlima    The total amount of KLIMA tokens to transfer and burn.
     * @param poolToken     The address of the pool token to burn KLIMA tokens for.
     */
    function transferAndBurnKlima(uint256 totalKlima, address poolToken) private {
        // Transfer and burn the KLIMA
        uint256 feeAmount = (totalKlima * daoFee[poolToken]) / FEE_DIVISOR;

        IKlima(KLIMA).safeTransferFrom(msg.sender, DAO, feeAmount);
        IKlima(KLIMA).burnFrom(msg.sender, totalKlima - feeAmount);

        emit KlimaBonded(feeAmount, totalKlima - feeAmount);
    }

    /**
     * @notice Returns the current market price of the pool token in terms of KLIMA tokens.
     * @dev Currently all KLIMA LP contracts safely interact with the IUniswapV2Pair abi.
     * @param poolToken The address of the pool token to get the market quote for.
     * @param amountOut The amount of pool tokens to get the market quote for.
     * @return currentPrice The current market price of the pool token in terms of KLIMA tokens.
     */
    function getMarketQuote(address poolToken, uint256 amountOut) internal view returns (uint256 currentPrice) {
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(poolReference[poolToken]).getReserves();

        currentPrice = referenceKlimaPosition[poolToken] == 0
            ? (amountOut * (reserve0)) / reserve1
            : (amountOut * (reserve1)) / reserve0;
    }

}
