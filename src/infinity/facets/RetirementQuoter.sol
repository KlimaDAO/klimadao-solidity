// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../libraries/LibAppStorage.sol";
import "../libraries/LibRetire.sol";
import "../libraries/TokenSwap/LibSwap.sol";
import "../C.sol";
import "../AppStorage.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IQuoterView.sol";

/**
 * @author Cujo
 * @title RetirementQuoter provides source token amount information for default trade paths defined within Klima Infinity
 */

contract RetirementQuoter {
    AppStorage internal s;

     function getSourceAmountSwapOnly(
        address sourceToken,
        address carbonToken,
        uint amountOut
    ) public view returns (uint amountIn) {

        (address originalSourceToken, address handledSourceToken) = handleSourceToken(sourceToken);

        uint256 swapSourceAmount = LibSwap.getSourceAmount(handledSourceToken, carbonToken, amountOut);

        uint additionalSwapAmount = calculateAdditionalSwapFee(originalSourceToken, swapSourceAmount);

        return swapSourceAmount + additionalSwapAmount;
    }

    function getSourceAmountDefaultRetirement(
        address sourceToken,
        address carbonToken,
        uint retireAmount
    ) public view returns (uint amountIn) {
        uint totalCarbon = LibRetire.getTotalCarbon(retireAmount);

        if (sourceToken == carbonToken) return totalCarbon;

        (address originalSourceToken, address handledSourceToken) = handleSourceToken(sourceToken);

        uint256 sourceAmount;

        if (IERC20(carbonToken).balanceOf(C.klimaRetirementBond()) >= totalCarbon){
            sourceAmount = LibSwap.getSourceAmountFromRetirementBond(handledSourceToken, carbonToken, totalCarbon);
        }
        else{
            sourceAmount = LibSwap.getSourceAmount(handledSourceToken, carbonToken, totalCarbon);
        }

        uint additionalSwapAmount = calculateAdditionalSwapFee(originalSourceToken, sourceAmount);

        return sourceAmount + additionalSwapAmount;
    }

    function getSourceAmountSpecificRetirement(
        address sourceToken,
        address carbonToken,
        uint retireAmount
    ) public view returns (uint amountIn) {
        uint totalCarbon = LibRetire.getTotalCarbonSpecific(carbonToken, retireAmount);

        if (sourceToken == carbonToken) return totalCarbon;

        (address originalSourceToken, address handledSourceToken) = handleSourceToken(sourceToken);

        uint256 sourceAmount;
   
        if (IERC20(carbonToken).balanceOf(C.klimaRetirementBond()) >= totalCarbon){
            sourceAmount = LibSwap.getSourceAmountFromRetirementBond(handledSourceToken, carbonToken, totalCarbon);
        } else {
            sourceAmount = LibSwap.getSourceAmount(handledSourceToken, carbonToken, totalCarbon);
        }

        uint256 additionalSwapAmount = calculateAdditionalSwapFee(originalSourceToken, sourceAmount);

        return sourceAmount + additionalSwapAmount;
    }

    function getSourceAmountDefaultRedeem(
        address sourceToken,
        address carbonToken,
        uint redeemAmount
    ) public view returns (uint amountIn) {
        if (sourceToken == carbonToken) return redeemAmount;

        (address originalSourceToken, address handledSourceToken) = handleSourceToken(sourceToken);

        uint256 swapSourceAmount = LibSwap.getSourceAmount(handledSourceToken, carbonToken, redeemAmount);

        uint additionalSwapAmount = calculateAdditionalSwapFee(originalSourceToken, swapSourceAmount);
        
        return swapSourceAmount + additionalSwapAmount;
    }

    function getSourceAmountSpecificRedeem(
        address sourceToken,
        address carbonToken,
        uint[] memory redeemAmounts
    ) public view returns (uint amountIn) {
        // Toucan Calculations
        if (s.poolBridge[carbonToken] == LibRetire.CarbonBridge.TOUCAN) {
            for (uint i; i < redeemAmounts.length; i++) {
                amountIn += redeemAmounts[i] + LibToucanCarbon.getSpecificRedeemFee(carbonToken, redeemAmounts[i]);
            }
        } else if (s.poolBridge[carbonToken] == LibRetire.CarbonBridge.C3) {
            for (uint i; i < redeemAmounts.length; i++) {
                amountIn +=
                    redeemAmounts[i] +
                    LibC3Carbon.getExactCarbonSpecificRedeemFee(carbonToken, redeemAmounts[i]);
            }
        }
        if (sourceToken != carbonToken) {
            (address originalSourceToken, address handledSourceToken) = handleSourceToken(sourceToken);

            uint256 swapSourceAmount = LibSwap.getSourceAmount(handledSourceToken, carbonToken, amountIn);

            uint additionalSwapAmount = calculateAdditionalSwapFee(originalSourceToken, swapSourceAmount);

            return swapSourceAmount + additionalSwapAmount;
        }
    }

    function getRetireAmountSourceDefault(
        address sourceToken,
        address carbonToken,
        uint amount
    ) public view returns (uint amountOut) {
        if (sourceToken == carbonToken) return amount - LibRetire.getFee(amount);

        uint totalSwap = LibSwap.getDefaultAmountOut(sourceToken, carbonToken, amount);
        return totalSwap - LibRetire.getFee(totalSwap);
    }

    function getRetireAmountSourceSpecific(
        address sourceToken,
        address carbonToken,
        uint amount
    ) public view returns (uint amountOut) {
        uint totalCarbon = amount;

        if (sourceToken != carbonToken) totalCarbon = LibSwap.getDefaultAmountOut(sourceToken, carbonToken, amount);

        amountOut = totalCarbon - LibRetire.getFee(totalCarbon);

        if (s.poolBridge[carbonToken] == LibRetire.CarbonBridge.TOUCAN) {
            amountOut = LibToucanCarbon.getSpecificRetireAmount(carbonToken, amountOut);
        } else if (s.poolBridge[carbonToken] == LibRetire.CarbonBridge.C3) {
            amountOut = LibC3Carbon.getExactSourceSpecificRetireAmount(carbonToken, amountOut);
        }
    }

    // USDC/USDC.e Uniswap Quote utils

    function handleSourceToken(address sourceToken) internal view returns (address originalSourceToken, address handledSourceToken) {
        originalSourceToken = sourceToken;
        handledSourceToken = sourceToken;
        if (sourceToken == C.usdc()) {
            handledSourceToken = C.usdc_bridged();
        }
        return (originalSourceToken, handledSourceToken);
    }

    function calculateAdditionalSwapFee(
        address originalSourceToken,
        uint256 sourceAmount
    ) internal view returns (uint256 additionalSwapAmount) {
        additionalSwapAmount = 0;
        if (originalSourceToken == C.usdc()) {
                additionalSwapAmount = getUniswapV3Quote(C.usdc(), C.usdc_bridged(), sourceAmount);
            }
        }


    function getUniswapV3Quote(address tokenIn, address tokenOut, uint256 amount) internal view returns (uint256 additionalSwapAmount) {
        IQuoterView.QuoteExactOutputSingleParams memory params = IQuoterView.QuoteExactOutputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            amount: amount,
            fee: 100,
            sqrtPriceLimitX96: 0
        });
        (uint256 amountIn, , , ) = IQuoterView(C.uniswapV3Quoter()).quoteExactOutputSingle(params);
        return amountIn > amount ? amountIn - amount: 0;
    }


}
