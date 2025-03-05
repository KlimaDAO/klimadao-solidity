// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../../ReentrancyGuard.sol";

contract BatchRetireFacet is ReentrancyGuard {

    struct Call {
        bytes callData; // Encoded call of a diamond retirement function
    }
    /**
     * Performs multiple retirements
     * Returns an array containing the retirementIndexes
     * The biggest uint256 represents an error
     */
    function batchRetire(
        Call[] calldata calls
    ) external payable nonBatchReentrant returns (uint256[] memory retirementIndexes)  {
        require (calls.length > 0, "callData cannot be empty");
        
        address diamondAddress = address(this); // Gets the diamond contract address

        bool hasSuccess = false; // Tracks a successfully permormed retirement

        uint256[] memory retirementIndexes = new uint256[](calls.length);

        for (uint i = 0; i < calls.length; i++) {
            // Execute call
            (bool success, bytes memory data) = diamondAddress.delegatecall(calls[i].callData);

            // Extract the retirement index
            if (success && data.length == 32) {
                retirementIndexes[i] = abi.decode(data, (uint256)) - 1;
                hasSuccess = true;
            }
            else {
                // type(uint256).max represents an error
                retirementIndexes[i] = type(uint256).max;
            }

            // Emit an event with the result of the call
            emit LibRetire.BatchedRetirementDone(success, retirementIndexes[i]);
        }
        require (hasSuccess, "No successful retirements performed"); // Reverts if no successful retirements occurs

        return retirementIndexes;
    }
}
