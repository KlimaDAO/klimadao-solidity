# IKlimaRetirementBond
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/29fd912e7e35bfd36ad9c6e57c2a312d3aed3640/src/protocol/interfaces/IKLIMA.sol)


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

