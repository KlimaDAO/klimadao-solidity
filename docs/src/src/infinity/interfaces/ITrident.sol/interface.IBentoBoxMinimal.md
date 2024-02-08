# IBentoBoxMinimal
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/704b462e69030cb9a43680057bee91d745d579ba/src/infinity/interfaces/ITrident.sol)


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

