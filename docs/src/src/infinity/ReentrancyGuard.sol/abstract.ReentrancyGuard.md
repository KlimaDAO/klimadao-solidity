# ReentrancyGuard
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/ReentrancyGuard.sol)

**Author:**
Beanstalk Farms


## State Variables
### _NOT_ENTERED

```solidity
uint private constant _NOT_ENTERED = 1;
```


### _ENTERED

```solidity
uint private constant _ENTERED = 2;
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

