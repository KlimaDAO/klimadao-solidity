# KlimaCirculatingSupplyContract
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/704b462e69030cb9a43680057bee91d745d579ba/src/protocol/staking/utils/KlimaCirculatingSupplyContract.sol)


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
function KLIMACirculatingSupply() external view returns (uint256);
```

### getNonCirculatingKLIMA


```solidity
function getNonCirculatingKLIMA() public view returns (uint256);
```

### setNonCirculatingKLIMAAddresses


```solidity
function setNonCirculatingKLIMAAddresses(address[] calldata _nonCirculatingAddresses) external returns (bool);
```

### transferOwnership


```solidity
function transferOwnership(address _owner) external returns (bool);
```

