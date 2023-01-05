// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
 * @author Cujo
 * @title LibUniswapV2Swap
 */

import "../../interfaces/IUniswapV2Router02.sol";
import "../Token/LibApprove.sol";

library LibUniswapV2Swap {
    function swapTokensForExactTokens(
        address router,
        address[] memory path,
        uint256 amountIn,
        uint256 amountOut
    ) internal returns (uint256) {
        LibApprove.approveToken(IERC20(path[0]), router, amountIn);

        uint256[] memory amountsOut = IUniswapV2Router02(router).swapTokensForExactTokens(
            amountOut,
            amountIn,
            path,
            address(this),
            block.timestamp
        );

        return amountsOut[path.length - 1];
    }

    function swapExactTokensForTokens(
        address router,
        address[] memory path,
        uint256 amount
    ) internal returns (uint256) {
        uint256[] memory amountsOut = IUniswapV2Router02(router).getAmountsOut(amount, path);

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

    function getAmountIn(
        address router,
        address[] memory path,
        uint256 amount
    ) internal view returns (uint256) {
        uint256[] memory amountsIn = IUniswapV2Router02(router).getAmountsIn(amount, path);
        return amountsIn[0];
    }
}
