// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../../libraries/LibRetire.sol";

contract RetireInfoFacet {
    /* == Getters == */

    function getTotalRetirements(address account) external view returns (uint totalRetirements) {
        return LibRetire.getTotalRetirements(account);
    }

    function getTotalCarbonRetired(address account) external view returns (uint totalCarbonRetired) {
        return LibRetire.getTotalCarbonRetired(account);
    }

    function getTotalPoolRetired(address account, address poolToken) external view returns (uint totalPoolRetired) {
        return LibRetire.getTotalPoolRetired(account, poolToken);
    }

    function getTotalProjectRetired(address account, address projectToken) external view returns (uint) {
        return LibRetire.getTotalProjectRetired(account, projectToken);
    }

    function getTotalRewardsClaimed(address account) external view returns (uint totalClaimed) {
        return LibRetire.getTotalRewardsClaimed(account);
    }

    function getRetirementDetails(address account, uint retirementIndex)
        external
        view
        returns (
            address poolTokenAddress,
            address projectTokenAddress,
            address beneficiaryAddress,
            string memory beneficiary,
            string memory retirementMessage,
            uint amount
        )
    {
        return LibRetire.getRetirementDetails(account, retirementIndex);
    }
}
