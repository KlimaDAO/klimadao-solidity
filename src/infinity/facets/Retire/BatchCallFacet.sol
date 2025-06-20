// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../../libraries/LibRetire.sol";

contract BatchCallFacet {
    struct Call {
        bytes callData; // Encoded call of a diamond retirement function
    }
    /**
     * Performs multiple calls to the diamond contract
     * Returns an array containing the calls return data
     * 0x represents an error
     */

    function batchCall(Call[] calldata calls) external payable returns (LibRetire.BatchedCallsData[] memory result) {
        require(calls.length > 0, "callData cannot be empty");

        address diamondAddress = address(this); // Gets the diamond contract address

        bool hasSuccess = false; // Tracks that at least one call was performed successfully

        LibRetire.BatchedCallsData[] memory result = new LibRetire.BatchedCallsData[](calls.length);

        for (uint256 i = 0; i < calls.length; i++) {
            // Execute call
            (bool success, bytes memory callData) = diamondAddress.delegatecall(calls[i].callData);

            //  Set the success and data for the call
            result[i].success = success;
            if (success) {
                result[i].data = callData;
                hasSuccess = true;
            } else {
                result[i].data = "0x";
            }
        }
        // Reverts if no successful calls occured
        require(hasSuccess, "No successful calls performed");

        // Emit an event with the call results and data
        emit LibRetire.BatchedCallsDone(result);

        return result;
    }
}
