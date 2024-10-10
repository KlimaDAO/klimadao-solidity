# IKlimaTreasury
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/protocol/interfaces/IKLIMA.sol)


## Functions
### excessReserves


```solidity
function excessReserves() external returns (uint256);
```

### manage


```solidity
function manage(address _token, uint256 _amount) external;
```

### queue


```solidity
function queue(uint8 _managing, address _address) external returns (bool);
```

### toggle


```solidity
function toggle(uint8 _managing, address _address, address _calculator) external returns (bool);
```

### ReserveManagerQueue


```solidity
function ReserveManagerQueue(address _address) external returns (uint256);
```

### isReserveManager


```solidity
function isReserveManager(address _address) external returns (bool);
```

