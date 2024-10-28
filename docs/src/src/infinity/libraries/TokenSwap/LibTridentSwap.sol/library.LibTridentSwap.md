# LibTridentSwap
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/infinity/libraries/TokenSwap/LibTridentSwap.sol)

**Author:**
Cujo


## Functions
### swapExactTokensForTokens


```solidity
function swapExactTokensForTokens(address router, address pool, address tokenIn, uint256 amountIn, uint256 minAmountOut)
    internal
    returns (uint256 amountOut);
```

### getAmountIn


```solidity
function getAmountIn(address pool, address tokenIn, address tokenOut, uint256 amountOut)
    internal
    view
    returns (uint256 amountIn);
```

### getAmountOut


```solidity
function getAmountOut(address pool, address tokenIn, address tokenOut, uint256 amountIn)
    internal
    view
    returns (uint256 amountOut);
```

### getTridentPool


```solidity
function getTridentPool(address tokenOne, address tokenTwo) internal view returns (address tridentPool);
```

