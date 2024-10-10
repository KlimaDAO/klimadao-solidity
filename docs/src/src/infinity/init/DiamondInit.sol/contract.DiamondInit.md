# DiamondInit
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/infinity/init/DiamondInit.sol)

\
Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
Implementation of a diamond.
/*****************************************************************************


## State Variables
### s

```solidity
AppStorage internal s;
```


### MAX_INT

```solidity
uint256 private constant MAX_INT = 2 ** 256 - 1;
```


## Functions
### init


```solidity
function init() external;
```

