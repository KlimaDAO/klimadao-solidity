# IKlimaRetirementBond
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/protocol/interfaces/IKLIMA.sol)


## Functions
### owner


```solidity
function owner() external returns (address);
```

### allocatorContract


```solidity
function allocatorContract() external returns (address);
```

### DAO


```solidity
function DAO() external returns (address);
```

### TREASURY


```solidity
function TREASURY() external returns (address);
```

### openMarket


```solidity
function openMarket(address poolToken) external;
```

### closeMarket


```solidity
function closeMarket(address poolToken) external;
```

### updateMaxSlippage


```solidity
function updateMaxSlippage(address poolToken, uint256 _maxSlippage) external;
```

### updateDaoFee


```solidity
function updateDaoFee(address poolToken, uint256 _daoFee) external;
```

### setPoolReference


```solidity
function setPoolReference(address poolToken, address referenceToken) external;
```

