// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
 * @author Cujo
 * @title LibUniswapV2Swap
 */

import "../../interfaces/IUniswapV2Router02.sol";
import "../Token/LibApprove.sol";
import "../LibAppStorage.sol";

library LibUniswapV2Swap {
    function swapTokensForExactTokens(
        address router,
        address[] memory path,
        uint amountIn,
        uint amountOut
    ) internal returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        LibApprove.approveToken(IERC20(path[0]), router, amountIn);

        if (s.swap[path[path.length - 1]][path[0]].transferFee) {
            IUniswapV2Router02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amountIn,
                amountOut,
                path,
                address(this),
                block.timestamp
            );

            // Given it's an exact token swap, amountOut is returned.
            // Though actual amount swapped maybe greater
            return amountOut;
        } else {
            uint[] memory amountsOut;

            amountsOut = IUniswapV2Router02(router).swapTokensForExactTokens(
                amountOut,
                amountIn,
                path,
                address(this),
                block.timestamp
            );

            return amountsOut[path.length - 1];
        }
    }

    function swapExactTokensForTokens(address router, address[] memory path, uint amount) internal returns (uint) {
        uint[] memory amountsOut = IUniswapV2Router02(router).getAmountsOut(amount, path);

        LibApprove.approveToken(IERC20(path[0]), router, amount);

        amountsOut = IUniswapV2Router02(router).swapExactTokensForTokens(
            amount,
            amountsOut[path.length - 1],
            path,
            address(this),
            block.timestamp
        );

        return amountsOut[path.length - 1];
    }

    function getAmountIn(address router, address[] memory path, uint amount) internal view returns (uint) {
        uint[] memory amountsIn = IUniswapV2Router02(router).getAmountsIn(amount, path);
        return amountsIn[0];
    }

    function getAmountOut(address router, address[] memory path, uint amount) internal view returns (uint) {
        uint[] memory amountsOut = IUniswapV2Router02(router).getAmountsOut(amount, path);
        return amountsOut[amountsOut.length - 1];
    }
}
