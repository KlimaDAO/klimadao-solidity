# ICarbonContractRegistry
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/infinity/interfaces/IInternationalCarbonRegistry.sol)


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

