// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../LibRetire.sol";
import "../Token/LibTransfer.sol";
import "../../interfaces/ICMARKCredit.sol";
import "../../C.sol";

import "lib/forge-std/src/console.sol";

/**
 * @author MarcusAurelius
 * @title LibCMARKCarbon
 */

library LibCMARKCarbon {
    event CarbonRetired(
        LibRetire.CarbonBridge carbonBridge,
        address indexed retiringAddress,
        string retiringEntityString,
        address indexed beneficiaryAddress,
        string beneficiaryString,
        string retirementMessage,
        address carbonToken,
        uint retiredAmount
    );

    /**
     * @notice                     Retire a CMARK project token
     * @param projectToken         Project token being retired
     * @param amount               Amount of tokens to retire
     * @param retiringAddress      Address initiating this retirement
     * @param retiringEntityString String description of the retiring entity
     * @param beneficiaryAddress   0x address for the beneficiary
     * @param beneficiaryString    String description of the beneficiary
     * @param retirementMessage    String message for this specific retirement
     */
    function retireCMARK(
        address poolToken,
        address projectToken,
        uint amount,
        LibRetire.RetireDetails memory details
    ) internal {
        ICMARKCreditToken(projectToken).retire(
            amount,
            details.beneficiaryAddress,
            details.beneficiaryString,
            details.retirementMessage,
            details.consumptionCountryCode
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
            LibRetire.CarbonBridge.C3,
            details.retiringAddress,
            details.retiringEntityString,
            details.beneficiaryAddress,
            details.beneficiaryString,
            details.retirementMessage,
            projectToken,
            amount
        );
    }

    function isValid(address token) internal returns (bool) {
        return ICMARKCreditTokenFactory(C.cMARKCreditFactory()).creditAddressToId(token) != '';
    }
}
