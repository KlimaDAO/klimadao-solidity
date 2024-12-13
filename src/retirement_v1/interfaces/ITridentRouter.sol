// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

/// @notice Trident pool router interface.
interface ITridentRouter {
    struct ExactInputSingleParams {
        uint256 amountIn;
        uint256 amountOutMinimum;
        address pool;
        address tokenIn;
        bytes data;
    }

    function exactInputSingleWithNativeToken(ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut);
}
