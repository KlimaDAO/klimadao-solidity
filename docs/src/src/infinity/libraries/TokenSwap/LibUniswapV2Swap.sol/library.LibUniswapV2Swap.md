# LibUniswapV2Swap
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/libraries/TokenSwap/LibUniswapV2Swap.sol)

**Author:**
Cujo


## Functions
### swapTokensForExactTokens


```solidity
function swapTokensForExactTokens(address router, address[] memory path, uint amountIn, uint amountOut)
    internal
    returns (uint);
```

### swapExactTokensForTokens


```solidity
function swapExactTokensForTokens(address router, address[] memory path, uint amount) internal returns (uint);
```

### getAmountIn


```solidity
function getAmountIn(address router, address[] memory path, uint amount) internal view returns (uint);
```

### getAmountOut


```solidity
function getAmountOut(address router, address[] memory path, uint amount) internal view returns (uint);
```

