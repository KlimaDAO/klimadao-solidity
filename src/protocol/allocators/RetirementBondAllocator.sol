// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import "oz/access/Ownable2Step.sol";
import "oz/token/ERC20/utils/SafeERC20.sol";

import {IKlima, IKlimaTreasury, IKlimaRetirementBond} from "../interfaces/IKLIMA.sol";

/**
 * @title RetirementBondAllocator
 * @author Cujo
 * @notice A contract for allocating retirement bonds using excess reserves from the Klima Treasury.
 */
contract RetirementBondAllocator is Ownable2Step {
    using SafeERC20 for IKlima;

    /// @notice Address of the Treasury contract.
    address public constant TREASURY = 0x7Dd4f0B986F032A44F913BF92c9e8b7c17D77aD7;
    /// @notice Address of the DAO multi-sig.
    address public constant DAO = 0x65A5076C0BA74e5f3e069995dc3DAB9D197d995c;

    /// @notice Maximum value of reserves or Treasury balance to allocate. Set by the DAO. 500 = 5%
    uint256 public maxReservePercent;
    /// @notice Divisor used when calculating percentages.
    uint256 public constant PERCENT_DIVISOR = 10_000;

    /// @notice Retirement bond contract being used.
    address public bondContract;

    event MaxPercentUpdated(uint256 oldMax, uint256 newMax);

    constructor(address _bondContract) {
        bondContract = _bondContract;
    }

    /**
     * @notice Modifier to ensure that the caller is the DAO multi-sig.
     */
    modifier onlyDAO() {
        require(msg.sender == DAO, "Caller must be DAO");
        _;
    }

    /**
     * @notice Funds retirement bonds with a specified amount of tokens.
     * @param token The address of the token to fund the retirement bonds with.
     * @param amount The amount of tokens to fund the retirement bonds with.
     */
    function fundBonds(address token, uint256 amount) external onlyOwner {
        // Limit the maximium amount of reserves that can be pulled from the treasury to the lower of the
        // excess reserves or tokens held by the treasury

        // Get excess reserves and convert 9 decimals to 18.
        uint256 currentExcessReserves = IKlimaTreasury(TREASURY).excessReserves() * 1e9;
        uint256 maxExcessReserves = (currentExcessReserves * maxReservePercent) / PERCENT_DIVISOR;
        uint256 maxTreasuryHoldings = (IKlima(token).balanceOf(TREASURY) * maxReservePercent) / PERCENT_DIVISOR;

        uint256 maxBondAmount = maxExcessReserves >= maxTreasuryHoldings ? maxTreasuryHoldings : maxExcessReserves;

        require(amount <= maxBondAmount, "Bond amount exceeds limit");

        IKlimaTreasury(TREASURY).manage(token, amount);
        IKlima(token).safeTransfer(bondContract, amount);
        IKlimaRetirementBond(bondContract).openMarket(token);
    }

    /**
     * @dev Closes the retirement bonds market for a specified token, transferring any remaining tokens to the treasury.
     * @param token The address of the token for which to close the retirement bonds market.
     */
    function closeBonds(address token) external onlyOwner {
        IKlimaRetirementBond(bondContract).closeMarket(token);

        // Extra gas and transfers no tokens, but does trigger a reserve update within the treasury.
        IKlimaTreasury(TREASURY).manage(token, 0);
    }

    /**
     * @notice Updates the retirement bond contract being used.
     * @param _bondContract The address of the new retirement bond contract.
     */
    function updateBondContract(address _bondContract) external onlyOwner {
        bondContract = _bondContract;
    }

    /**
     * @dev Updates the maximum reserve percentage allowed.
     * @param _maxReservePercent The new maximum reserve percentage allowed. 500 = 5%.
     */
    function updateMaxReservePercent(uint256 _maxReservePercent) external onlyDAO {
        uint256 oldMax = maxReservePercent;
        maxReservePercent = _maxReservePercent;

        emit MaxPercentUpdated(oldMax, maxReservePercent);
    }
}
