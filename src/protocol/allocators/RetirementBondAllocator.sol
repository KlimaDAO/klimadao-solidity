// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "oz/access/Ownable2Step.sol";
import "../interfaces/IKLIMA.sol";

contract RetirementBondAllocator is Ownable2Step {
    using SafeERC20 for IKlima;

    address public constant TREASURY = 0x7Dd4f0B986F032A44F913BF92c9e8b7c17D77aD7;
    address public bondContract;

    constructor(address _bondContract) {
        bondContract = _bondContract;
    }

    function fundBonds(address token, uint amount) external onlyOwner {
        IKlimaTreasury(TREASURY).manage(token, amount);
        IKlima(token).transfer(bondContract, amount);
    }

    function closeBonds(address token) external onlyOwner {
        IKlimaRetirementBond(bondContract).closeMarket(token);

        // Extra gas and transfers no tokens, but does trigger a reserve update within the treasury.
        IKlimaTreasury(TREASURY).manage(token, 0);
    }

    function updateBondContract(address _bondContract) external onlyOwner {
        bondContract = _bondContract;
    }
}
