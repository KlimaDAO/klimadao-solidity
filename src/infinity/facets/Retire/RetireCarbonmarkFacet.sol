// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {LibRetire, C, LibApprove} from "../../libraries/LibRetire.sol";
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
     * @param retiringEntityString String description of the retiring entity
     * @param beneficiaryAddress   0x address for the beneficiary
     * @param beneficiaryString    String description of the beneficiary
     * @param retirementMessage    String message for this specific retirement
     * @param fromMode             From Mode for transfering tokens
     * @return retirementIndex     The latest retirement index for the beneficiary address
     */
    function retireCarbonmarkListing(
        ICarbonmark.CreditListing memory listing,
        uint256 maxAmountIn,
        uint256 retireAmount,
        string memory retiringEntityString,
        address beneficiaryAddress,
        string memory beneficiaryString,
        string memory retirementMessage,
        LibTransfer.From fromMode
    ) external payable nonReentrant returns (uint256 retirementIndex) {
        require(retireAmount > 0, "Cannot retire zero tonnes");

        LibTransfer.receiveToken(IERC20(C.usdc()), maxAmountIn, msg.sender, fromMode);

        LibApprove.approveToken(IERC20(C.usdc()), C.carbonmark(), maxAmountIn);

        ICarbonmark(C.carbonmark()).fillListing(
            listing.id, listing.account, listing.token, listing.unitPrice, retireAmount, maxAmountIn
        );

        LibRetire.retireReceivedCreditToken(
            listing.token,
            retireAmount,
            msg.sender,
            retiringEntityString,
            beneficiaryAddress,
            beneficiaryString,
            retirementMessage
        );

        return LibRetire.getTotalRetirements(beneficiaryAddress);
    }
}
