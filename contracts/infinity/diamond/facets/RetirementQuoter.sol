// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "../../libraries/LibAppStorage.sol";
import "../../libraries/LibRetire.sol";
import "../../libraries/TokenSwap/LibSwap.sol";
import "../../C.sol";

/**
 * @author Cujo
 * @title RetirementQuoter provides source token amount information for default trade paths defined within Klima Infinity
 */

contract RetirementQuoter {
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
}
