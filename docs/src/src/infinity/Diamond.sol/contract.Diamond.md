# Diamond
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/Diamond.sol)

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


## Functions
### constructor


```solidity
constructor(address _contractOwner, address _diamondCutFacet) payable;
```

### fallback


```solidity
fallback() external payable;
```

### receive


```solidity
receive() external payable;
```

