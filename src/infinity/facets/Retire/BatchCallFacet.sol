// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../../ReentrancyGuard.sol";

contract BatchCallFacet is ReentrancyGuard {

    struct Call {
        bytes callData; // Encoded call of a diamond retirement function
    }
    /**
     * Performs multiple calls to the diamond contract
     * Returns an array containing the calls results
     * The biggest uint256 represents an error
     */
    function batchCall(
        Call[] calldata calls
    ) external payable nonBatchReentrant returns (uint256[] memory results)  {
        require (calls.length > 0, "callData cannot be empty");
        
        address diamondAddress = address(this); // Gets the diamond contract address

        bool hasSuccess = false; // Tracks a successfully permormed call

        uint256[] memory results = new uint256[](calls.length);

        for (uint i = 0; i < calls.length; i++) {
            // Execute call
            (bool success, bytes memory data) = diamondAddress.delegatecall(calls[i].callData);

            // Extract the call result
            if (success && data.length == 32) {
                results[i] = abi.decode(data, (uint256)) - 1;
                hasSuccess = true;
            }
            else {
                // type(uint256).max represents an error
                results[i] = type(uint256).max;
            }

        }
        // Emit an event with the call results
        emit LibRetire.BatchedCallsDone(results);

        require (hasSuccess, "No successful calls performed"); // Reverts if no successful calls occured

        return results;
    }
}
