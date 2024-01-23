# DiamondInit
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/init/DiamondInit.sol)

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
uint private constant MAX_INT = 2 ** 256 - 1;
```


## Functions
### init


```solidity
function init() external;
```

