# TWAPOracleUpdater
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/tokens/regular/KlimaToken.sol)

**Inherits:**
[ERC20Permit](/src/protocol/tokens/regular/KlimaToken.sol/abstract.ERC20Permit.md), [VaultOwned](/src/protocol/tokens/regular/KlimaToken.sol/contract.VaultOwned.md)


## State Variables
### _dexPoolsTWAPSources

```solidity
EnumerableSet.AddressSet private _dexPoolsTWAPSources;
```


### twapOracle

```solidity
ITWAPOracle public twapOracle;
```


### twapEpochPeriod

```solidity
uint public twapEpochPeriod;
```


## Functions
### constructor


```solidity
constructor(string memory name_, string memory symbol_, uint8 decimals_) ERC20(name_, symbol_, decimals_);
```

### changeTWAPOracle


```solidity
function changeTWAPOracle(address newTWAPOracle_) external onlyOwner;
```

### changeTWAPEpochPeriod


```solidity
function changeTWAPEpochPeriod(uint newTWAPEpochPeriod_) external onlyOwner;
```

### addTWAPSource


```solidity
function addTWAPSource(address newTWAPSourceDexPool_) external onlyOwner;
```

### removeTWAPSource


```solidity
function removeTWAPSource(address twapSourceToRemove_) external onlyOwner;
```

### _uodateTWAPOracle


```solidity
function _uodateTWAPOracle(address dexPoolToUpdateFrom_, uint twapEpochPeriodToUpdate_) internal;
```

### _beforeTokenTransfer


```solidity
function _beforeTokenTransfer(address from_, address to_, uint amount_) internal virtual override;
```

## Events
### TWAPOracleChanged

```solidity
event TWAPOracleChanged(address indexed previousTWAPOracle, address indexed newTWAPOracle);
```

### TWAPEpochChanged

```solidity
event TWAPEpochChanged(uint previousTWAPEpochPeriod, uint newTWAPEpochPeriod);
```

### TWAPSourceAdded

```solidity
event TWAPSourceAdded(address indexed newTWAPSource);
```

### TWAPSourceRemoved

```solidity
event TWAPSourceRemoved(address indexed removedTWAPSource);
```

