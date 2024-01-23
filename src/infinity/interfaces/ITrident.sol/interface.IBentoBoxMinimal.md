# IBentoBoxMinimal
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/infinity/interfaces/ITrident.sol)


## Functions
### setMasterContractApproval

*Approves users' BentoBox assets to a "master" contract.*


```solidity
function setMasterContractApproval(address user, address masterContract, bool approved, uint8 v, bytes32 r, bytes32 s)
    external;
```

### toAmount


```solidity
function toAmount(IERC20 token, uint256 share, bool roundUp) external view returns (uint256 amount);
```

