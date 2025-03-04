// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../../ReentrancyGuard.sol";

contract BatchRetireFacet is ReentrancyGuard {
    event BatchedRetirementCalled(bool selector, uint256 retirementIndex);

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
        // Gets the diamond contract address
        address diamondAddress = address(this);

        uint256[] memory retirementIndexes = new uint256[](calls.length);

        for (uint i = 0; i < calls.length; i++) {

            // Execute call to the retirement function
            (bool success, bytes memory data) = diamondAddress.delegatecall(calls[i].callData);

            // Extract the retirement index
            uint256 retirementIndex;
            if (success) {
                require(data.length == 32, "Invalid byte length for retirement call result");
                retirementIndex = abi.decode(data, (uint256));
            }
            else {
                // The biggest uint256 represents an error
                retirementIndex = type(uint256).max;
            }

            // Emit an event with the result of the call
            emit BatchedRetirementCalled(success, retirementIndex);

            // record the retirementIndex
            retirementIndexes[i] = retirementIndex;
        }
        return retirementIndexes;
    }
}
