# IUniswapV2Factory
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/integrations/sushixklima/SushiRouterV02.sol)


## Functions
### feeTo


```solidity
function feeTo() external view returns (address);
```

### feeToSetter


```solidity
function feeToSetter() external view returns (address);
```

### migrator


```solidity
function migrator() external view returns (address);
```

### getPair


```solidity
function getPair(address tokenA, address tokenB) external view returns (address pair);
```

### allPairs


```solidity
function allPairs(uint) external view returns (address pair);
```

### allPairsLength


```solidity
function allPairsLength() external view returns (uint);
```

### createPair


```solidity
function createPair(address tokenA, address tokenB) external returns (address pair);
```

### setFeeTo


```solidity
function setFeeTo(address) external;
```

### setFeeToSetter


```solidity
function setFeeToSetter(address) external;
```

### setMigrator


```solidity
function setMigrator(address) external;
```

## Events
### PairCreated

```solidity
event PairCreated(address indexed token0, address indexed token1, address pair, uint);
```

