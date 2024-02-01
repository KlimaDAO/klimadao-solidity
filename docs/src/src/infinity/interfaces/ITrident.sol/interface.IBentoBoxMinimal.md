# IBentoBoxMinimal
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/infinity/interfaces/ITrident.sol)


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

