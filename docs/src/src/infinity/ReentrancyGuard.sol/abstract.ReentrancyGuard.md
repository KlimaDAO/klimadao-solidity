# ReentrancyGuard
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/infinity/ReentrancyGuard.sol)

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

