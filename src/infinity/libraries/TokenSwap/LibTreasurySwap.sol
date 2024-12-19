// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
 * @author Cujo
 * @title LibTreasurySwap
 */
import {IKlimaRetirementBond} from "../../interfaces/IKlima.sol";
import "../Token/LibApprove.sol";
import "../../C.sol";

library LibTreasurySwap {
    function getAmountIn(address tokenIn, uint256 amountOut) internal view returns (uint256 amountIn) {
        return IKlimaRetirementBond(C.klimaRetirementBond()).getKlimaAmount(amountOut, tokenIn);
    }

    function swapToExact(address carbonToken, uint256 amountIn, uint256 amountOut) internal {
        LibApprove.approveToken(IERC20(C.klima()), C.klimaRetirementBond(), amountIn);

        IKlimaRetirementBond(C.klimaRetirementBond()).swapToExact(carbonToken, amountOut);
    }
}
