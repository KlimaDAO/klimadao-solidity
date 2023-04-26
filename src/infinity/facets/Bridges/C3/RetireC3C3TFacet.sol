// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../../../libraries/Bridges/LibC3Carbon.sol";
import "../../../libraries/LibRetire.sol";
import "../../../libraries/TokenSwap/LibSwap.sol";
import "../../../ReentrancyGuard.sol";

contract RetireC3C3TFacet is ReentrancyGuard {
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
     * @notice This contract assumes that the token being provided is a raw TCO2 token.
     *  @notice The transactions will revert otherwise.
     */

    /**
     * @notice                     Redeems C3T directly
     * @param carbonToken          Pool token to redeem
     * @param amount               Amounts of underlying tokens to redeem
     * @param beneficiaryAddress   0x address for the beneficiary
     * @param beneficiaryString    String description of the beneficiary
     * @param retirementMessage    String message for this specific retirement
     * @param fromMode             From Mode for transfering tokens
     * @return retirementIndex     The latest retirement index for the beneficiary address
     */
    function c3RetireExactC3T(
        address carbonToken,
        uint amount,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        LibTransfer.From fromMode
    ) external nonReentrant returns (uint retirementIndex) {
        // Currently this is a simple wrapper for direct calls on specific TCO2 tokens
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
        uint amount,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        LibTransfer.From fromMode
    ) external nonReentrant returns (uint retirementIndex) {
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
