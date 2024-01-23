# LibTridentSwap
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/infinity/libraries/TokenSwap/LibTridentSwap.sol)

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

