// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../../../libraries/Bridges/LibC3Carbon.sol";
import "../../../ReentrancyGuard.sol";
import "../../../libraries/TokenSwap/LibSwap.sol";

contract RedeemC3PoolFacet is ReentrancyGuard {
    /**
     * @notice                 Redeems default underlying carbon tokens from a C3 Pool
     * @param sourceToken      Source token to use in the redemption
     * @param poolToken        Pool token to redeem
     * @param amount           Amount to redeem
     * @param maxAmountIn      Max amount of source token to spend
     * @param fromMode         From Mode for transfering tokens
     * @param toMode           To Mode for where undlerying tokens are sent
     * @return projectTokens   List of underlying tokens received
     * @return amounts         Amounts of underlying tokens received
     */
    function c3RedeemPoolDefault(
        address sourceToken,
        address poolToken,
        uint256 amount,
        uint256 maxAmountIn,
        LibTransfer.From fromMode,
        LibTransfer.To toMode
    ) external nonReentrant returns (address[] memory projectTokens, uint256[] memory amounts) {
        require(toMode == LibTransfer.To.EXTERNAL, "Internal balances not live");
        require(amount > 0, "Cannot redeem zero tokens");

        address originalSourceToken = sourceToken;

        LibTransfer.receiveToken(IERC20(sourceToken), maxAmountIn, msg.sender, fromMode);

        // after this point the contract has bridged usdc
        if (sourceToken == C.usdc()) {
            (sourceToken, maxAmountIn) = LibSwap.swapNativeUsdcToBridgedUsdc(maxAmountIn);
            // set the original source token to return trade dust in the correct token
            originalSourceToken = C.usdc();
        }

        if (sourceToken != poolToken) {
            if (sourceToken == C.wsKlima()) {
                maxAmountIn = LibKlima.unwrapKlima(maxAmountIn);
            }
            if (sourceToken == C.sKlima()) LibKlima.unstakeKlima(maxAmountIn);

            uint256 carbonReceived = LibSwap.swapToExactCarbonDefault(sourceToken, poolToken, maxAmountIn, amount);

            require(carbonReceived >= amount, "Swap not enough");
            amount = carbonReceived;

            // Check for any trade dust and send back
            LibSwap.returnTradeDust(originalSourceToken, poolToken);
        }

        (projectTokens, amounts) = LibC3Carbon.redeemPoolAuto(poolToken, amount, toMode);
    }

    /**
     * @notice                     Redeems default underlying carbon tokens from a C3 Pool
     * @param sourceToken          Source token to use in the redemption
     * @param poolToken            Pool token to redeem
     * @param maxAmountIn          Max amount of source token to spend
     * @param projectTokens        Underlying tokens to redeem
     * @param amounts              Amounts of underlying tokens to redeem
     * @param fromMode             From Mode for transfering tokens
     * @param toMode               To Mode for where undlerying tokens are sent
     * @return redeemedAmounts     Amounts of underlying tokens redeemed
     */
    function c3RedeemPoolSpecific(
        address sourceToken,
        address poolToken,
        uint256 maxAmountIn,
        address[] memory projectTokens,
        uint256[] memory amounts,
        LibTransfer.From fromMode,
        LibTransfer.To toMode
    ) external nonReentrant returns (uint256[] memory redeemedAmounts) {
        require(toMode == LibTransfer.To.EXTERNAL, "Internal balances not live");
        require(projectTokens.length == amounts.length, "Array lengths not equal");

        uint256 totalCarbon;
        address originalSourceToken = sourceToken;

        for (uint256 i; i < amounts.length; i++) {
            totalCarbon += amounts[i] + LibC3Carbon.getExactCarbonSpecificRedeemFee(poolToken, amounts[i]);
        }

        require(totalCarbon > 0, "Cannot redeem zero tokens");

        uint256 receivedAmount = LibTransfer.receiveToken(IERC20(sourceToken), maxAmountIn, msg.sender, fromMode);

        if (sourceToken == C.usdc()) {
            (sourceToken, maxAmountIn) = LibSwap.swapNativeUsdcToBridgedUsdc(maxAmountIn);
            // set the original source token to return trade dust in the correct token
            originalSourceToken = C.usdc();
        }

        if (sourceToken != poolToken) {
            if (sourceToken == C.wsKlima()) {
                maxAmountIn = LibKlima.unwrapKlima(maxAmountIn);
            }
            if (sourceToken == C.sKlima()) LibKlima.unstakeKlima(maxAmountIn);

            receivedAmount = LibSwap.swapToExactCarbonDefault(sourceToken, poolToken, maxAmountIn, totalCarbon);

            // Check for any trade dust and send back
            LibSwap.returnTradeDust(originalSourceToken, poolToken);
        }

        require(receivedAmount >= totalCarbon, "Not enough pool tokens");

        redeemedAmounts = LibC3Carbon.redeemPoolSpecific(poolToken, projectTokens, amounts, toMode);

        // Check for any redeem dust and send to the treasury
        /// @dev This is due to the fact that you can't swap for an exact token amount in Trident

        uint256 poolBalance = IERC20(poolToken).balanceOf(address(this));
        if (poolBalance > 0) {
            LibTransfer.sendToken(IERC20(poolToken), poolBalance, C.treasury(), LibTransfer.To.EXTERNAL);
        }
    }
}
