// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../../../../C.sol";
import "../../../../libraries/Bridges/LibToucanCarbon.sol";
import "../../../../libraries/LibRetire.sol";
import "../../../../libraries/TokenSwap/LibSwap.sol";
import "../../../../libraries/Bridges/LibToucanCarbon.sol";
import "../../../ReentrancyGuard.sol";

contract RedeemToucanPoolFacet is ReentrancyGuard {
    /**
     * @notice                 Redeems default underlying carbon tokens from a Toucan Pool
     * @param poolToken        Pool token to redeem
     * @param amount           Amount to redeem
     * @param fromMode         From Mode for transfering tokens
     * @param toMode           To Mode for where undlerying tokens are sent
     * @return projectTokens   List of underlying tokens received
     * @return amounts         Amounts of underlying tokens received
     */
    function toucan_redeemPoolDefault(
        address poolToken,
        uint256 amount,
        LibTransfer.From fromMode,
        LibTransfer.To toMode
    ) external nonReentrant returns (address[] memory projectTokens, uint256[] memory amounts) {
        require(toMode == LibTransfer.To.EXTERNAL, "Internal balances not live");
        (projectTokens, amounts) = LibToucanCarbon.redeemPoolAuto(poolToken, amount, fromMode, toMode);
    }

    /**
     * @notice                     Redeems default underlying carbon tokens from a Toucan Pool
     * @param poolToken            Pool token to redeem
     * @param projectTokens        Underlying tokens to redeem
     * @param amounts              Amounts of underlying tokens to redeem
     * @param fromMode             From Mode for transfering tokens
     * @param toMode               To Mode for where undlerying tokens are sent
     * @return redeemedAmounts     Amounts of underlying tokens redeemed
     */
    function toucan_redeemPoolSpecific(
        address poolToken,
        address[] memory projectTokens,
        uint256[] memory amounts,
        LibTransfer.From fromMode,
        LibTransfer.To toMode
    ) external nonReentrant returns (uint256[] memory redeemedAmounts) {
        require(toMode == LibTransfer.To.EXTERNAL, "Internal balances not live");
        require(projectTokens.length == amounts.length, "Array lengths not equal");
        redeemedAmounts = LibToucanCarbon.redeemPoolSpecific(poolToken, projectTokens, amounts, fromMode, toMode);
    }
}
