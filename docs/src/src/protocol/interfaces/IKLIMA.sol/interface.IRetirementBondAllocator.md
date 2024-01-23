# IRetirementBondAllocator
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/interfaces/IKLIMA.sol)


## Functions
### fundBonds


```solidity
function fundBonds(address token, uint amount) external;
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
function updateMaxReservePercent(uint _maxReservePercent) external;
```

### maxReservePercent


```solidity
function maxReservePercent() external view returns (uint);
```

### PERCENT_DIVISOR


```solidity
function PERCENT_DIVISOR() external view returns (uint);
```

