// SPDX-License-Identifier: MIT
pragma solidity =0.8.16;

import "../../C.sol";
import "../LibRetire.sol";
import "../../interfaces/IInternationalCarbonRegistry.sol";

/**
 * @author Cujo
 * @title LibICRCarbon
 * Handles interactions with ICR carbon credits
 */
library LibICRCarbon {
    event CarbonRetired(
        LibRetire.CarbonBridge carbonBridge,
        address indexed retiringAddress,
        string retiringEntityString,
        address indexed beneficiaryAddress,
        string beneficiaryString,
        string retirementMessage,
        address indexed carbonPool,
        address carbonToken,
        uint256 tokenId,
        uint256 retiredAmount
    );

    function retireICC(
        address poolToken,
        address projectToken,
        uint256 tokenId,
        uint256 amount,
        LibRetire.RetireDetails memory details
    ) internal returns (uint256 retiredAmount) {
        bytes memory data;

        IProject(projectToken).retire(
            tokenId, amount, details.beneficiaryAddress, details.beneficiaryString, "", details.retirementMessage, data
        );

        LibRetire.saveRetirementDetails(
            poolToken,
            projectToken,
            amount,
            details.beneficiaryAddress,
            details.beneficiaryString,
            details.retirementMessage
        );

        emit CarbonRetired(
            LibRetire.CarbonBridge.ICR,
            details.retiringAddress,
            details.retiringEntityString,
            details.beneficiaryAddress,
            details.beneficiaryString,
            details.retirementMessage,
            poolToken,
            projectToken,
            tokenId,
            amount
        );

        return amount;
    }

    function isValid(address token) internal view returns (bool) {
        return ICarbonContractRegistry(C.icrProjectRegistry()).getProjectIdFromAddress(token) != 0;
    }
}
