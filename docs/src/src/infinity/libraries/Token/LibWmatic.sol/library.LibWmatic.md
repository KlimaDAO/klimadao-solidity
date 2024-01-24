# LibWmatic
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/29fd912e7e35bfd36ad9c6e57c2a312d3aed3640/src/infinity/libraries/Token/LibWmatic.sol)

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

