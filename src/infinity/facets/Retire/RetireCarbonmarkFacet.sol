// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {LibRetire, C, LibApprove, LibTransfer} from "../../libraries/LibRetire.sol";
import {ICarbonmark} from "../../interfaces/ICarbonmark.sol";
import "../../ReentrancyGuard.sol";

contract RetireCarbonmarkFacet is ReentrancyGuard {
    event CarbonRetired(
        LibRetire.CarbonBridge carbonBridge,
        address indexed retiringAddress,
        string retiringEntityString,
        address indexed beneficiaryAddress,
        string beneficiaryString,
        string retirementMessage,
        address indexed carbonPool,
        address poolToken,
        uint256 retiredAmount
    );

    /* ========== Retire directly from a Carbonmark listing ========== */

    /**
     * @notice                     Retires an exact amount of carbon using default redemption
     * @param maxAmountIn          Maximum amount of USDC tokens to spend for this retirement
     * @param retireAmount         The amount of carbon to retire
     * @param details              Encoded struct of retirement details needed for the retirement
     * @param fromMode             From Mode for transfering tokens
     * @return retirementIndex     The latest retirement index for the beneficiary address
     */
    function retireCarbonmarkListing(
        ICarbonmark.CreditListing memory listing,
        uint256 maxAmountIn,
        uint256 retireAmount,
        LibRetire.RetireDetails memory details,
        LibTransfer.From fromMode
    ) external payable nonReentrant returns (uint256 retirementIndex) {
        require(retireAmount > 0, "Cannot retire zero tonnes");

        uint256 balance = IERC20(C.usdc()).balanceOf(msg.sender);
        address purchaseToken;

        if (balance >= maxAmountIn) {
            purchaseToken = C.usdc();
        } else {
            purchaseToken = C.usdc_bridged();
        }

        LibTransfer.receiveToken(IERC20(purchaseToken), maxAmountIn, msg.sender, fromMode);

        LibApprove.approveToken(IERC20(purchaseToken), C.carbonmark(), maxAmountIn);

        ICarbonmark(C.carbonmark()).fillListing(
            listing.id, listing.account, listing.token, listing.unitPrice, retireAmount, maxAmountIn
        );

        uint256 dustBalance = IERC20(purchaseToken).balanceOf(address(this));

        if (dustBalance != 0) {
            LibTransfer.sendToken(IERC20(purchaseToken), dustBalance, msg.sender, LibTransfer.To.EXTERNAL);
        }

        if (details.retiringAddress == address(0)) details.retiringAddress = msg.sender;

        LibRetire.retireReceivedCreditToken(listing.token, listing.tokenId, retireAmount, details);

        return LibRetire.getTotalRetirements(details.beneficiaryAddress);
    }
}
