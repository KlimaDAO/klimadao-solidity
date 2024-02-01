# ICarbonContractRegistry
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/704b462e69030cb9a43680057bee91d745d579ba/src/infinity/interfaces/IInternationalCarbonRegistry.sol)


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

