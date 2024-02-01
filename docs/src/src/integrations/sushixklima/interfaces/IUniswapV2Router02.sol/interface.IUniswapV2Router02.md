# IUniswapV2Router02
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/integrations/sushixklima/interfaces/IUniswapV2Router02.sol)

**Inherits:**
[IUniswapV2Router01](/src/infinity/interfaces/IUniswapV2Router01.sol/interface.IUniswapV2Router01.md)


## Functions
### removeLiquidityETHSupportingFeeOnTransferTokens


```solidity
function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
) external returns (uint256 amountETH);
```

### removeLiquidityETHWithPermitSupportingFeeOnTransferTokens


```solidity
function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
) external returns (uint256 amountETH);
```

### swapExactTokensForTokensSupportingFeeOnTransferTokens


```solidity
function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
) external;
```

### swapExactETHForTokensSupportingFeeOnTransferTokens


```solidity
function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
) external payable;
```

### swapExactTokensForETHSupportingFeeOnTransferTokens


```solidity
function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
) external;
```

