// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../../libraries/LibAppStorage.sol";
import "../../libraries/LibRetire.sol";
import "../../libraries/TokenSwap/LibSwap.sol";
import "../../C.sol";
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
        uint256 amountOut
    ) public view returns (uint256 amountIn) {
        return LibSwap.getSourceAmount(sourceToken, carbonToken, amountOut);
    }

    function getSourceAmountDefaultRetirement(
        address sourceToken,
        address carbonToken,
        uint256 retireAmount
    ) public view returns (uint256 amountIn) {
        uint256 totalCarbon = LibRetire.getTotalCarbon(retireAmount);
        if (sourceToken == carbonToken) return totalCarbon;
        return LibSwap.getSourceAmount(sourceToken, carbonToken, totalCarbon);
    }

    function getSourceAmountSpecificRetirement(
        address sourceToken,
        address carbonToken,
        uint256 retireAmount
    ) public view returns (uint256 amountIn) {
        uint256 totalCarbon = LibRetire.getTotalCarbonSpecific(carbonToken, retireAmount);
        if (sourceToken == carbonToken) return totalCarbon;
        return LibSwap.getSourceAmount(sourceToken, carbonToken, totalCarbon);
    }

    function getSourceAmountDefaultRedeem(
        address sourceToken,
        address carbonToken,
        uint256 redeemAmount
    ) public view returns (uint256 amountIn) {
        if (sourceToken == carbonToken) return redeemAmount;
        return LibSwap.getSourceAmount(sourceToken, carbonToken, redeemAmount);
    }

    function getSourceAmountSpecificRedeem(
        address sourceToken,
        address carbonToken,
        uint256[] memory redeemAmounts
    ) public view returns (uint256 amountIn) {
        // Toucan Calculations
        if (s.poolBridge[carbonToken] == LibRetire.CarbonBridge.TOUCAN) {
            for (uint256 i; i < redeemAmounts.length; i++) {
                amountIn += redeemAmounts[i] + LibToucanCarbon.getSpecificRedeemFee(carbonToken, redeemAmounts[i]);
            }
        } else if (s.poolBridge[carbonToken] == LibRetire.CarbonBridge.C3) {
            for (uint256 i; i < redeemAmounts.length; i++) {
                amountIn +=
                    redeemAmounts[i] +
                    LibC3Carbon.getExactCarbonSpecificRedeemFee(carbonToken, redeemAmounts[i]);
            }
        }
        if (sourceToken != carbonToken) return LibSwap.getSourceAmount(sourceToken, carbonToken, amountIn);
    }
}
