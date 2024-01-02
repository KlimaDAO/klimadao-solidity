// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@axelar-network/axelar-cgp-solidity/contracts/interfaces/IAxelarAuth.sol";
import "@axelar-network/axelar-cgp-solidity/contracts/Ownable.sol";

contract AuthModuleMock is Ownable, IAxelarAuth {
    function validateProof(bytes32 messageHash, bytes calldata proof) external returns (bool currentOperators) {
        return true;
    }

    function transferOperatorship(bytes calldata params) external {

    }
}