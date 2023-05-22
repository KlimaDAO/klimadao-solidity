// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import "oz/access/Ownable2Step.sol";
import "oz/token/ERC20/utils/SafeERC20.sol";

import {IKlima, IKlimaTreasury, IKlimaRetirementBond} from "../interfaces/IKLIMA.sol";

contract RetirementBondAllocator is Ownable2Step {
    using SafeERC20 for IKlima;

    address public constant TREASURY = 0x7Dd4f0B986F032A44F913BF92c9e8b7c17D77aD7;
    address public constant DAO = 0x65A5076C0BA74e5f3e069995dc3DAB9D197d995c;

    uint256 public maxReservePercent;
    uint256 public constant PERCENT_DIVISOR = 10_000;

    address public bondContract;

    event MaxPercentUpdated(uint256 oldMax, uint256 newMax);

    constructor(address _bondContract) {
        bondContract = _bondContract;
    }

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
        IKlima(token).transfer(bondContract, amount);
        IKlimaRetirementBond(bondContract).openMarket(token);
    }

    function closeBonds(address token) external onlyOwner {
        IKlimaRetirementBond(bondContract).closeMarket(token);

        // Extra gas and transfers no tokens, but does trigger a reserve update within the treasury.
        IKlimaTreasury(TREASURY).manage(token, 0);
    }

    function updateBondContract(address _bondContract) external onlyOwner {
        bondContract = _bondContract;
    }

    function updateMaxReservePercent(uint256 maxPercent) external {
        enforceOnlyDao();

        uint256 oldMax = maxReservePercent;
        maxReservePercent = maxPercent;

        emit MaxPercentUpdated(oldMax, maxReservePercent);
    }

    function enforceOnlyDao() private view {
        require(msg.sender == DAO, "Caller must be DAO");
    }
}
