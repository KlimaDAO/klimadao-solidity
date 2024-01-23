# UniswapV2Library
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/integrations/sushixklima/SushiRouterV02.sol)


## Functions
### sortTokens


```solidity
function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1);
```

### pairFor


```solidity
function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair);
```

### getReserves


```solidity
function getReserves(address factory, address tokenA, address tokenB)
    internal
    view
    returns (uint reserveA, uint reserveB);
```

### quote


```solidity
function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB);
```

### getAmountOut


```solidity
function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut);
```

### getAmountIn


```solidity
function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn);
```

### getAmountsOut


```solidity
function getAmountsOut(address factory, uint amountIn, address[] memory path)
    internal
    view
    returns (uint[] memory amounts);
```

### getAmountsIn


```solidity
function getAmountsIn(address factory, uint amountOut, address[] memory path)
    internal
    view
    returns (uint[] memory amounts);
```

