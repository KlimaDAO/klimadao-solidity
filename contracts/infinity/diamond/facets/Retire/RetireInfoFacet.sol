// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../../../libraries/LibRetire.sol";

contract RetireInfoFacet {
    /* == Getters == */

    function getTotalRetirements(address account) external view returns (uint256 totalRetirements) {
        return LibRetire.getTotalRetirements(account);
    }

    function getTotalCarbonRetired(address account) external view returns (uint256 totalCarbonRetired) {
        return LibRetire.getTotalCarbonRetired(account);
    }

    function getTotalPoolRetired(address account, address poolToken) external view returns (uint256 totalPoolRetired) {
        return LibRetire.getTotalPoolRetired(account, poolToken);
    }

    function getTotalProjectRetired(address account, address projectToken) external view returns (uint256) {
        return LibRetire.getTotalProjectRetired(account, projectToken);
    }

    function getTotalRewardsClaimed(address account) external view returns (uint256 totalClaimed) {
        return LibRetire.getTotalRewardsClaimed(account);
    }

    function getRetirementDetails(address account, uint256 retirementIndex)
        external
        view
        returns (
            address poolTokenAddress,
            address projectTokenAddress,
            address beneficiaryAddress,
            string memory beneficiary,
            string memory retirementMessage,
            uint256 amount
        )
    {
        return LibRetire.getRetirementDetails(account, retirementIndex);
    }
}
