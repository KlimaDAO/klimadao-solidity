# UniswapV2Router02
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/integrations/sushixklima/SushiRouterV02.sol)

**Inherits:**
[IUniswapV2Router02](/src/retirement_v1/interfaces/IUniswapV2Router02.sol/interface.IUniswapV2Router02.md)


## State Variables
### factory

```solidity
address public immutable override factory;
```


### WETH

```solidity
address public immutable override WETH;
```


## Functions
### ensure


```solidity
modifier ensure(uint deadline);
```

### constructor


```solidity
constructor(address _factory, address _WETH) public;
```

### receive


```solidity
receive() external payable;
```

### _addLiquidity


```solidity
function _addLiquidity(
    address tokenA,
    address tokenB,
    uint amountADesired,
    uint amountBDesired,
    uint amountAMin,
    uint amountBMin
) internal virtual returns (uint amountA, uint amountB);
```

### addLiquidity


```solidity
function addLiquidity(
    address tokenA,
    address tokenB,
    uint amountADesired,
    uint amountBDesired,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
) external virtual override ensure(deadline) returns (uint amountA, uint amountB, uint liquidity);
```

### addLiquidityETH


```solidity
function addLiquidityETH(
    address token,
    uint amountTokenDesired,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
) external payable virtual override ensure(deadline) returns (uint amountToken, uint amountETH, uint liquidity);
```

### removeLiquidity


```solidity
function removeLiquidity(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
) public virtual override ensure(deadline) returns (uint amountA, uint amountB);
```

### removeLiquidityETH


```solidity
function removeLiquidityETH(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
) public virtual override ensure(deadline) returns (uint amountToken, uint amountETH);
```

### removeLiquidityWithPermit


```solidity
function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
) external virtual override returns (uint amountA, uint amountB);
```

### removeLiquidityETHWithPermit


```solidity
function removeLiquidityETHWithPermit(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
) external virtual override returns (uint amountToken, uint amountETH);
```

### removeLiquidityETHSupportingFeeOnTransferTokens


```solidity
function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
) public virtual override ensure(deadline) returns (uint amountETH);
```

### removeLiquidityETHWithPermitSupportingFeeOnTransferTokens


```solidity
function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
) external virtual override returns (uint amountETH);
```

### _swap


```solidity
function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual;
```

### swapExactTokensForTokens


```solidity
function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    virtual
    override
    ensure(deadline)
    returns (uint[] memory amounts);
```

### swapTokensForExactTokens


```solidity
function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    virtual
    override
    ensure(deadline)
    returns (uint[] memory amounts);
```

### swapExactETHForTokens


```solidity
function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    virtual
    override
    ensure(deadline)
    returns (uint[] memory amounts);
```

### swapTokensForExactETH


```solidity
function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    virtual
    override
    ensure(deadline)
    returns (uint[] memory amounts);
```

### swapExactTokensForETH


```solidity
function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    virtual
    override
    ensure(deadline)
    returns (uint[] memory amounts);
```

### swapETHForExactTokens


```solidity
function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    virtual
    override
    ensure(deadline)
    returns (uint[] memory amounts);
```

### _swapSupportingFeeOnTransferTokens


```solidity
function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual;
```

### swapExactTokensForTokensSupportingFeeOnTransferTokens


```solidity
function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
) external virtual override ensure(deadline);
```

### swapExactETHForTokensSupportingFeeOnTransferTokens


```solidity
function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
) external payable virtual override ensure(deadline);
```

### swapExactTokensForETHSupportingFeeOnTransferTokens


```solidity
function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
) external virtual override ensure(deadline);
```

### quote


```solidity
function quote(uint amountA, uint reserveA, uint reserveB) public pure virtual override returns (uint amountB);
```

### getAmountOut


```solidity
function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut)
    public
    pure
    virtual
    override
    returns (uint amountOut);
```

### getAmountIn


```solidity
function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut)
    public
    pure
    virtual
    override
    returns (uint amountIn);
```

### getAmountsOut


```solidity
function getAmountsOut(uint amountIn, address[] memory path)
    public
    view
    virtual
    override
    returns (uint[] memory amounts);
```

### getAmountsIn


```solidity
function getAmountsIn(uint amountOut, address[] memory path)
    public
    view
    virtual
    override
    returns (uint[] memory amounts);
```

