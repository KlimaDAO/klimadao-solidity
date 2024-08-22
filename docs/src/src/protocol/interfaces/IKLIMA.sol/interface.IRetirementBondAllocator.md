# IRetirementBondAllocator
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/protocol/interfaces/IKLIMA.sol)


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

