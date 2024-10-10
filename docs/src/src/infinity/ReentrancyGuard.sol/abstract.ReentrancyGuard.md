# ReentrancyGuard
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/infinity/ReentrancyGuard.sol)

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

