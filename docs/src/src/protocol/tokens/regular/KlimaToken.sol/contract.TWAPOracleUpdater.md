# TWAPOracleUpdater
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/protocol/tokens/regular/KlimaToken.sol)

**Inherits:**
[ERC20Permit](/src/protocol/tokens/regular/sKlimaToken_v2.sol/abstract.ERC20Permit.md), [VaultOwned](/src/protocol/tokens/regular/KlimaToken.sol/contract.VaultOwned.md)


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
uint256 public twapEpochPeriod;
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
function changeTWAPEpochPeriod(uint256 newTWAPEpochPeriod_) external onlyOwner;
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
function _uodateTWAPOracle(address dexPoolToUpdateFrom_, uint256 twapEpochPeriodToUpdate_) internal;
```

### _beforeTokenTransfer


```solidity
function _beforeTokenTransfer(address from_, address to_, uint256 amount_) internal virtual override;
```

## Events
### TWAPOracleChanged

```solidity
event TWAPOracleChanged(address indexed previousTWAPOracle, address indexed newTWAPOracle);
```

### TWAPEpochChanged

```solidity
event TWAPEpochChanged(uint256 previousTWAPEpochPeriod, uint256 newTWAPEpochPeriod);
```

### TWAPSourceAdded

```solidity
event TWAPSourceAdded(address indexed newTWAPSource);
```

### TWAPSourceRemoved

```solidity
event TWAPSourceRemoved(address indexed removedTWAPSource);
```

