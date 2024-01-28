// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
 * @author Cujo
 * @title LibUniswapV3Swap
 */

import "../../interfaces/IUniswapV3.sol";
import "../Token/LibApprove.sol";
import "../LibAppStorage.sol";
import "../../C.sol";

library LibUniswapV3Swap {
    function exactOutputSingle(
        address router,
        address tokenIn,
        address tokenOut,
        uint256 minAmountOut,
        uint256 maxAmountIn
    ) internal returns (uint256 amountOut) {
        LibApprove.approveToken(IERC20(tokenIn), router, maxAmountIn);

        ISwapRouter.ExactOutputSingleParams memory swapParams = ISwapRouter.ExactOutputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: 3000,
            recipient: address(this),
            deadline: block.timestamp,
            amountOut: minAmountOut,
            amountInMaximum: maxAmountIn,
            sqrtPriceLimitX96: 0
        });

        ISwapRouter(router).exactOutputSingle(swapParams);

        amountOut = minAmountOut;
    }
}
