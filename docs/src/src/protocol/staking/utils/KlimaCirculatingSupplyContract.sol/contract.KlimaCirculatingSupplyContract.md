# KlimaCirculatingSupplyContract
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/staking/utils/KlimaCirculatingSupplyContract.sol)


## State Variables
### isInitialized

```solidity
bool public isInitialized;
```


### KLIMA

```solidity
address public KLIMA;
```


### owner

```solidity
address public owner;
```


### nonCirculatingKLIMAAddresses

```solidity
address[] public nonCirculatingKLIMAAddresses;
```


## Functions
### constructor


```solidity
constructor(address _owner);
```

### initialize


```solidity
function initialize(address _klima) external returns (bool);
```

### KLIMACirculatingSupply


```solidity
function KLIMACirculatingSupply() external view returns (uint);
```

### getNonCirculatingKLIMA


```solidity
function getNonCirculatingKLIMA() public view returns (uint);
```

### setNonCirculatingKLIMAAddresses


```solidity
function setNonCirculatingKLIMAAddresses(address[] calldata _nonCirculatingAddresses) external returns (bool);
```

### transferOwnership


```solidity
function transferOwnership(address _owner) external returns (bool);
```

