# ICarbonContractRegistry
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/infinity/interfaces/IInternationalCarbonRegistry.sol)


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

