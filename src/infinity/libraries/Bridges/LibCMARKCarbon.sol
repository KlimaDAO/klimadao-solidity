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
        address indexed carbonPool,
        address carbonToken,
        uint retiredAmount
    );

    /**
     * @notice                     Retire a CMARK project token
     * @param projectToken         Project token being retired
     * @param amount               Amount of tokens to retire
     * @param details              Encoded struct of retirement details needed for the retirement
     */
    function retireCMARK(
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
            address(0),
            projectToken,
            amount,
            details.beneficiaryAddress,
            details.beneficiaryString,
            details.retirementMessage
        );

        emit CarbonRetired(
            LibRetire.CarbonBridge.CMARK,
            details.retiringAddress,
            details.retiringEntityString,
            details.beneficiaryAddress,
            details.beneficiaryString,
            details.retirementMessage,
            address(0),
            projectToken,
            amount
        );
    }

    function isValid(address token) internal returns (bool) {
        bytes memory tempEmptyStringTest = bytes(ICMARKCreditTokenFactory(C.cmarkCreditFactory()).creditAddressToId(token));
        return tempEmptyStringTest.length > 0;
    }
}
