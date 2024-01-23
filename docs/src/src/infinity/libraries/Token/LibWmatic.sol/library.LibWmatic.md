# LibWmatic
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/libraries/Token/LibWmatic.sol)

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
function wrap(uint amount, LibTransfer.To mode) internal;
```

### unwrap


```solidity
function unwrap(uint amount, LibTransfer.From mode) internal;
```

### deposit


```solidity
function deposit(uint amount) private;
```

### withdraw


```solidity
function withdraw(uint amount) private;
```

