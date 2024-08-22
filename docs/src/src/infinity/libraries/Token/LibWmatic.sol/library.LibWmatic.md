# LibWmatic
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/infinity/libraries/Token/LibWmatic.sol)

**Author:**
Cujo


## State Variables
### WMATIC

```solidity
address constant WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
```


## Functions
### wrap


```solidity
function wrap(uint256 amount, LibTransfer.To mode) internal;
```

### unwrap


```solidity
function unwrap(uint256 amount, LibTransfer.From mode) internal;
```

### deposit


```solidity
function deposit(uint256 amount) private;
```

### withdraw


```solidity
function withdraw(uint256 amount) private;
```

