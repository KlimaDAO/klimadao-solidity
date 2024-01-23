# LibTridentSwap
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/libraries/TokenSwap/LibTridentSwap.sol)

**Author:**
Cujo


## Functions
### swapExactTokensForTokens


```solidity
function swapExactTokensForTokens(address router, address pool, address tokenIn, uint amountIn, uint minAmountOut)
    internal
    returns (uint amountOut);
```

### getAmountIn


```solidity
function getAmountIn(address pool, address tokenIn, address tokenOut, uint amountOut)
    internal
    view
    returns (uint amountIn);
```

### getAmountOut


```solidity
function getAmountOut(address pool, address tokenIn, address tokenOut, uint amountIn)
    internal
    view
    returns (uint amountOut);
```

### getTridentPool


```solidity
function getTridentPool(address tokenOne, address tokenTwo) internal view returns (address tridentPool);
```

