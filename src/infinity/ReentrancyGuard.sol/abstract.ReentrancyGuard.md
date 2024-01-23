# ReentrancyGuard
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/infinity/ReentrancyGuard.sol)

**Author:**
Beanstalk Farms


## State Variables
### _NOT_ENTERED

```solidity
uint256 private constant _NOT_ENTERED = 1;
```


### _ENTERED

```solidity
uint256 private constant _ENTERED = 2;
```


### s

```solidity
AppStorage internal s;
```


## Functions
### nonReentrant


```solidity
modifier nonReentrant();
```

