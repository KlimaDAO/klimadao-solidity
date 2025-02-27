// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../../ReentrancyGuard.sol";

contract BatchRetireFacet is ReentrancyGuard {
    event BatchedRetirementCalled(bool selector, uint256 retirementIndex);

    struct Call {
        bytes callData; // Encoded function call
    }

    function batchRetire(
        Call[] calldata calls
    ) external payable nonReentrant {
        // Gets the diamond contract address
         address diamondAddress = address(this);

         for (uint i = 0; i < calls.length; i++) {

            // Execute call to the retirement function
            (bool success, bytes memory data) = diamondAddress.call(calls[i].callData);

            // Extract retirement index
            uint256 retirementIndex;
            if (success) {
                require(data.length == 32, "Invalid byte length for retirement call result");
                retirementIndex = abi.decode(data, (uint256));
            }
            else {
                retirementIndex = 0;
            }

            // Emit an event with the result of the call
            emit BatchedRetirementCalled(success, retirementIndex);
        }
    }
}
