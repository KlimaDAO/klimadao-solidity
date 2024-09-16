// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IERC173} from "../interfaces/IERC173.sol";

contract OwnershipFacet is IERC173 {
    function transferOwnership(address _newOwner) external override {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.startTransferOwnership(_newOwner);
    }

    function acceptOwnership() external {
        LibDiamond.enforceIsPendingOwner();
        LibDiamond.transferContractOwner();
    }

    function owner() external view override returns (address owner_) {
        owner_ = LibDiamond.contractOwner();
    }

    function pendingOwner() external view returns (address pendingOwner_) {
        pendingOwner_ = LibDiamond.pendingOwner();
    }
}
