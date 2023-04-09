// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
 * @author Cujo
 * @title LibTreasurySwap
 */

import "../../interfaces/IKlimaRetirementBond.sol";
import "../Token/LibApprove.sol";
import "../../C.sol";

library LibTreasurySwap {
    function getAmountIn(address tokenIn, uint amountOut) internal view returns (uint amountIn) {
        return IKlimaRetirementBond(C.klimaRetirementBond()).getKlimaAmount(amountOut, tokenIn);
    }

    function swapToExact(address carbonToken, uint amountIn, uint amountOut) internal {
        LibApprove.approveToken(IERC20(carbonToken), C.klimaRetirementBond(), amountIn);

        IKlimaRetirementBond(C.klimaRetirementBond()).swapToExact(carbonToken, amountOut);
    }
}
