# ICarbonContractRegistry
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/infinity/interfaces/IInternationalCarbonRegistry.sol)


## Functions
### getTokenVaultBeaconAddress


```solidity
function getTokenVaultBeaconAddress() external view returns (address);
```

### getVerifiedVaultAddress


```solidity
function getVerifiedVaultAddress(uint256 id) external view returns (address);
```

### getSerializationAddress


```solidity
function getSerializationAddress(string calldata serialization) external view returns (address);
```

### getProjectAddressFromId


```solidity
function getProjectAddressFromId(uint256 projectId) external view returns (address);
```

### getProjectIdFromAddress


```solidity
function getProjectIdFromAddress(address projectAddress) external view returns (uint256);
```

### getBeaconAddress


```solidity
function getBeaconAddress() external view returns (address);
```

