# ReentrancyGuard
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/704b462e69030cb9a43680057bee91d745d579ba/src/infinity/ReentrancyGuard.sol)

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

