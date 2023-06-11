// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../libraries/LibAppStorage.sol";
import "../libraries/LibRetire.sol";
import "../libraries/TokenSwap/LibSwap.sol";
import "../C.sol";
import "../AppStorage.sol";

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
        return LibSwap.getSourceAmount(sourceToken, carbonToken, amountOut);
    }

    function getSourceAmountDefaultRetirement(
        address sourceToken,
        address carbonToken,
        uint retireAmount
    ) public view returns (uint amountIn) {
        uint totalCarbon = LibRetire.getTotalCarbon(retireAmount);

        if (sourceToken == carbonToken) return totalCarbon;

        if (IERC20(carbonToken).balanceOf(C.klimaRetirementBond()) >= totalCarbon)
            return LibSwap.getSourceAmountFromRetirementBond(sourceToken, carbonToken, totalCarbon);

        return LibSwap.getSourceAmount(sourceToken, carbonToken, totalCarbon);
    }

    function getSourceAmountSpecificRetirement(
        address sourceToken,
        address carbonToken,
        uint retireAmount
    ) public view returns (uint amountIn) {
        uint totalCarbon = LibRetire.getTotalCarbonSpecific(carbonToken, retireAmount);

        if (sourceToken == carbonToken) return totalCarbon;

        if (IERC20(carbonToken).balanceOf(C.klimaRetirementBond()) >= totalCarbon)
            return LibSwap.getSourceAmountFromRetirementBond(sourceToken, carbonToken, totalCarbon);

        return LibSwap.getSourceAmount(sourceToken, carbonToken, totalCarbon);
    }

    function getSourceAmountDefaultRedeem(
        address sourceToken,
        address carbonToken,
        uint redeemAmount
    ) public view returns (uint amountIn) {
        if (sourceToken == carbonToken) return redeemAmount;
        
        return LibSwap.getSourceAmount(sourceToken, carbonToken, redeemAmount);
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
            return LibSwap.getSourceAmount(sourceToken, carbonToken, amountIn);
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
}
