# LibTridentSwap
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/infinity/libraries/TokenSwap/LibTridentSwap.sol)

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

