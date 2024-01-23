# IBentoBoxMinimal
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/interfaces/ITrident.sol)


## Functions
### setMasterContractApproval

*Approves users' BentoBox assets to a "master" contract.*


```solidity
function setMasterContractApproval(address user, address masterContract, bool approved, uint8 v, bytes32 r, bytes32 s)
    external;
```

### toAmount


```solidity
function toAmount(IERC20 token, uint share, bool roundUp) external view returns (uint amount);
```

