// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../../../libraries/Bridges/LibICRCarbon.sol";
import "../../../libraries/LibRetire.sol";
import "../../../ReentrancyGuard.sol";

contract RetireICRFacet is ReentrancyGuard {
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

    /**
     * @notice This contract assumes that the token being provided is a raw ICR project token.
     *  @notice The transactions will revert otherwise.
     */

    /**
     * @notice                     Redeems ICR credit directly
     * @param projectToken         Project token address
     * @param tokenId              Token ID for project to retire
     * @param amount               Amounts of underlying tokens to redeem
     * @param retiringEntityString String description for the retiring entity
     * @param beneficiaryAddress   0x address for the beneficiary
     * @param beneficiaryString    String description of the beneficiary
     * @param retirementMessage    String message for this specific retirement
     * @param fromMode             From Mode for transfering tokens
     * @return retirementIndex     The latest retirement index for the beneficiary address
     */
    function icrRetireExactCarbon(
        address projectToken,
        uint256 tokenId,
        uint256 amount,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        LibTransfer.From fromMode
    ) external nonReentrant returns (uint256 retirementIndex) {
        // Currently this is a simple wrapper for direct calls on specific ICR tokens
        // No fee is charged

        LibTransfer.receive1155Token(IERC1155(projectToken), tokenId, amount, msg.sender, fromMode);

        LibRetire.RetireDetails memory details;

        details.retiringAddress = msg.sender;
        details.retiringEntityString = retiringEntityString;
        details.beneficiaryAddress = beneficiaryAddress;
        details.beneficiaryString = beneficiaryString;
        details.retirementMessage = retirementMessage;

        // Retire the carbon
        LibICRCarbon.retireICC(
            address(0), // Direct retirement, no pool token
            projectToken,
            tokenId,
            amount,
            details
        );

        return LibRetire.getTotalRetirements(beneficiaryAddress);
    }
}
