# IDiamond
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/704b462e69030cb9a43680057bee91d745d579ba/src/infinity/interfaces/IDiamond.sol)

\
Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/*****************************************************************************


## Events
### DiamondCut

```solidity
event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
```

## Structs
### FacetCut

```solidity
struct FacetCut {
    address facetAddress;
    FacetCutAction action;
    bytes4[] functionSelectors;
}
```

## Enums
### FacetCutAction

```solidity
enum FacetCutAction {
    Add,
    Replace,
    Remove
}
```

