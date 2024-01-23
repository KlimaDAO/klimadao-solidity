# IKlimaTreasury
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/interfaces/IKLIMA.sol)


## Functions
### excessReserves


```solidity
function excessReserves() external returns (uint);
```

### manage


```solidity
function manage(address _token, uint _amount) external;
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
function ReserveManagerQueue(address _address) external returns (uint);
```

