// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
 * @author Cujo
 * @title LibTridentSwap
 */

import "../../interfaces/ITrident.sol";
import "../Token/LibApprove.sol";
import "../LibAppStorage.sol";
import "../../C.sol";

library LibTridentSwap {
    function swapExactTokensForTokens(address router, address pool, address tokenIn, uint amountIn, uint minAmountOut)
        internal
        returns (uint amountOut)
    {
        ITridentRouter.ExactInputSingleParams memory swapParams;
        swapParams.amountIn = amountIn;
        swapParams.amountOutMinimum = minAmountOut;
        swapParams.pool = pool;
        swapParams.tokenIn = tokenIn;
        swapParams.data = abi.encode(tokenIn, address(this), true);
        amountOut = ITridentRouter(router).exactInputSingleWithNativeToken(swapParams);
    }

    function getAmountIn(address pool, address tokenIn, address tokenOut, uint amountOut)
        internal
        view
        returns (uint amountIn)
    {
        uint shareAmount = ITridentPool(pool).getAmountIn(abi.encode(tokenOut, amountOut));
        amountIn = IBentoBoxMinimal(C.sushiBento()).toAmount(IERC20(tokenIn), shareAmount, true);
    }

    function getTridentPool(address tokenOne, address tokenTwo) internal view returns (address tridentPool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.tridentPool[tokenOne][tokenTwo] == address(0)
            ? s.tridentPool[tokenTwo][tokenOne]
            : s.tridentPool[tokenOne][tokenTwo];
    }
}
