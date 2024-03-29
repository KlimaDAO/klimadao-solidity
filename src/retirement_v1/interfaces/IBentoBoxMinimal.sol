// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

interface IBentoBoxMinimal {
    /// @dev Approves users' BentoBox assets to a "master" contract.
    function setMasterContractApproval(
        address user,
        address masterContract,
        bool approved,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}
