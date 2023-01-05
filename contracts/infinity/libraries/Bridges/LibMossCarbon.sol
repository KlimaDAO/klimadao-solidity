// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../../C.sol";
import "../LibRetire.sol";
import "../Token/LibApprove.sol";
import "../../interfaces/ICarbonChain.sol";

/**
 * @author Cujo
 * @title LibMossCarbon
 */

library LibMossCarbon {
    using LibApprove for IERC20;

    event CarbonRetired(
        LibRetire.CarbonBridge carbonBridge,
        address indexed retiringAddress,
        string retiringEntityString,
        address indexed beneficiaryAddress,
        string beneficiaryString,
        string retirementMessage,
        address indexed carbonPool,
        address carbonToken,
        uint256 retiredAmount
    );

    /**
     * @notice                      Retires Moss MCO2 tokens on Polygon
     * @param poolToken             Pool token to use for this retirement
     * @param amount                Amounts of the project tokens to retire
     * @param retiringAddress      Address initiating this retirement
     * @param retiringEntityString String description of the retiring entity
     * @param beneficiaryAddress   0x address for the beneficiary
     * @param beneficiaryString    String description of the beneficiary
     * @param retirementMessage    String message for this specific retirement
     */
    function offsetCarbon(
        address poolToken,
        uint256 amount,
        address retiringAddress,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage
    ) internal {
        // Retire MCO2
        LibApprove.approveToken(IERC20(poolToken), C.mossCarbonChain(), amount);
        ICarbonChain(C.mossCarbonChain()).offsetCarbon(amount, retirementMessage, beneficiaryString);

        LibRetire.saveRetirementDetails(
            poolToken,
            address(0), // MCO2 does not have an underlying project token.
            amount,
            beneficiaryAddress,
            beneficiaryString,
            retirementMessage
        );

        emit CarbonRetired(
            LibRetire.CarbonBridge.MOSS,
            retiringAddress,
            retiringEntityString,
            beneficiaryAddress,
            beneficiaryString,
            retirementMessage,
            poolToken,
            address(0), // MCO2 does not have an underlying project token.
            amount
        );
    }
}
