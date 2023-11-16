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

    function retireICR(
        address poolToken,
        address projectToken,
        uint256 tokenId,
        uint256 amount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage
    ) internal returns (uint256 retiredAmount) {
        bytes memory data;
        IProject(projectToken).retire(
            tokenId, amount, beneficiaryAddress, beneficiaryString, "", retirementMessage, data
        );

        LibRetire.saveRetirementDetails(
            poolToken, projectToken, amount, beneficiaryAddress, beneficiaryString, retirementMessage
        );

        emit CarbonRetired(
            LibRetire.CarbonBridge.ICR,
            retiringAddress,
            retiringEntityString,
            beneficiaryAddress,
            beneficiaryString,
            retirementMessage,
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
