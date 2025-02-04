// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../../../libraries/Bridges/LibCMARKCarbon.sol";
import "../../../libraries/LibRetire.sol";
import "../../../libraries/TokenSwap/LibSwap.sol";
import "../../../ReentrancyGuard.sol";

contract RetireCMARKFacet is ReentrancyGuard {
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
     * @notice This contract assumes that the token being provided is a raw CMARK credit token.
     *  @notice The transactions will revert otherwise.
     */

    /**
     * @notice                     Retires CMARK credits directly
     * @param carbonToken          Pool token to redeem
     * @param amount               Amounts of underlying tokens to redeem
     * @param details              Encoded struct of retirement details needed for the retirement
     * @param fromMode             From Mode for transfering tokens
     * @return retirementIndex     The latest retirement index for the beneficiary address
     */
    function cmarkRetireExactCarbon(
        address carbonToken,
        uint amount,
        LibRetire.RetireDetails memory details,
        LibTransfer.From fromMode
    ) external nonReentrant returns (uint retirementIndex) {
        // Currently this is a simple wrapper for direct calls on specific CMARK tokens
        // No fee is charged

        LibTransfer.receiveToken(IERC20(carbonToken), amount, msg.sender, fromMode);

        if (details.retiringAddress == address(0)) details.retiringAddress = msg.sender;

        bytes memory tempEmptyStringTest = bytes(details.retiringEntityString);
        if (tempEmptyStringTest.length == 0)  {
            details.retiringEntityString = "KlimaDAO Retirement Aggregator";
        }

        // Retire the carbon
        LibCMARKCarbon.retireCMARK(
            carbonToken,
            amount,
            details
        );

        return LibRetire.getTotalRetirements(details.beneficiaryAddress);
    }
}
