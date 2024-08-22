# LibUniswapV2Swap
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/infinity/libraries/TokenSwap/LibUniswapV2Swap.sol)

**Author:**
Cujo


## Functions
### swapTokensForExactTokens


```solidity
function swapTokensForExactTokens(address router, address[] memory path, uint256 amountIn, uint256 amountOut)
    internal
    returns (uint256);
```

### swapExactTokensForTokens


```solidity
function swapExactTokensForTokens(address router, address[] memory path, uint256 amount) internal returns (uint256);
```

### getAmountIn


```solidity
function getAmountIn(address router, address[] memory path, uint256 amount) internal view returns (uint256);
```

### getAmountOut


```solidity
function getAmountOut(address router, address[] memory path, uint256 amount) internal view returns (uint256);
```

