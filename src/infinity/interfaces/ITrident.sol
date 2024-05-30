// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "oz-4-8-3/token/ERC20/IERC20.sol";

interface IBentoBoxMinimal {
    /// @dev Approves users' BentoBox assets to a "master" contract.
    function setMasterContractApproval(
        address user,
        address masterContract,
        bool approved,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function toAmount(IERC20 token, uint share, bool roundUp) external view returns (uint amount);
}

/// @notice Trident pool router interface.
interface ITridentRouter {
    struct ExactInputSingleParams {
        uint amountIn;
        uint amountOutMinimum;
        address pool;
        address tokenIn;
        bytes data;
    }

    function exactInputSingleWithNativeToken(ExactInputSingleParams calldata params)
        external
        payable
        returns (uint amountOut);
}

/// @notice Trident pool interface.
interface ITridentPool {
    /// @notice Simulates a trade and returns the expected output.
    /// @dev The pool does not need to include a trade simulator directly in itself - it can use a library.
    /// @param data ABI-encoded params that the pool requires.
    /// @return finalAmountOut The amount of output tokens that will be sent to the user if the trade is executed.
    function getAmountOut(bytes calldata data) external view returns (uint finalAmountOut);

    /// @notice Simulates a trade and returns the expected output.
    /// @dev The pool does not need to include a trade simulator directly in itself - it can use a library.
    /// @param data ABI-encoded params that the pool requires.
    /// @return finalAmountIn The amount of input tokens that are required from the user if the trade is executed.
    function getAmountIn(bytes calldata data) external view returns (uint finalAmountIn);
}
