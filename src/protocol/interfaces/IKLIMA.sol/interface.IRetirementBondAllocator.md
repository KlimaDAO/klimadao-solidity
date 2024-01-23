# IRetirementBondAllocator
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/protocol/interfaces/IKLIMA.sol)


## Functions
### owner


```solidity
function owner() external returns (address);
```

### fundBonds


```solidity
function fundBonds(address token, uint256 amount) external;
```

### closeBonds


```solidity
function closeBonds(address token) external;
```

### updateBondContract


```solidity
function updateBondContract(address _bondContract) external;
```

### updateMaxReservePercent


```solidity
function updateMaxReservePercent(uint256 _maxReservePercent) external;
```

### maxReservePercent


```solidity
function maxReservePercent() external view returns (uint256);
```

### PERCENT_DIVISOR


```solidity
function PERCENT_DIVISOR() external view returns (uint256);
```

