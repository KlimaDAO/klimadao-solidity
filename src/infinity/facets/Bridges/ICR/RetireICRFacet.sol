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
     * @param carbonToken          Project token address
     * @param tokenId              Token ID for project to retire
     * @param amount               Amounts of underlying tokens to redeem
     * @param beneficiaryAddress   0x address for the beneficiary
     * @param beneficiaryString    String description of the beneficiary
     * @param retirementMessage    String message for this specific retirement
     * @param fromMode             From Mode for transfering tokens
     * @return retirementIndex     The latest retirement index for the beneficiary address
     */
    function c3RetireExactC3T(
        address carbonToken,
        uint256 amount,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        LibTransfer.From fromMode
    ) external nonReentrant returns (uint256 retirementIndex) {
        // Currently this is a simple wrapper for direct calls on specific ICR tokens
        // No fee is charged

        LibTransfer.receiveToken(IERC20(carbonToken), amount, msg.sender, fromMode);

        // Retire the carbon
        LibC3Carbon.retireC3T(
            address(0), // Direct retirement, no pool token
            carbonToken,
            amount,
            msg.sender,
            "KlimaDAO Retirement Aggregator",
            beneficiaryAddress,
            beneficiaryString,
            retirementMessage
        );

        return LibRetire.getTotalRetirements(beneficiaryAddress);
    }

    /**
     * @notice                     Redeems C3T directly
     * @param carbonToken          Pool token to redeem
     * @param amount               Amounts of underlying tokens to redeem
     * @param retiringEntityString String description of the retiring entity
     * @param beneficiaryAddress   0x address for the beneficiary
     * @param beneficiaryString    String description of the beneficiary
     * @param retirementMessage    String message for this specific retirement
     * @param fromMode             From Mode for transfering tokens
     * @return retirementIndex     The latest retirement index for the beneficiary address
     */
    function c3RetireExactC3TWithEntity(
        address carbonToken,
        uint256 amount,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        LibTransfer.From fromMode
    ) external nonReentrant returns (uint256 retirementIndex) {
        // Currently this is a simple wrapper for direct calls on specific TCO2 tokens
        // No fee is charged

        LibTransfer.receiveToken(IERC20(carbonToken), amount, msg.sender, fromMode);

        // Retire the carbon
        LibC3Carbon.retireC3T(
            address(0), // Direct retirement, no pool token
            carbonToken,
            amount,
            msg.sender,
            retiringEntityString,
            beneficiaryAddress,
            beneficiaryString,
            retirementMessage
        );

        return LibRetire.getTotalRetirements(beneficiaryAddress);
    }
}
