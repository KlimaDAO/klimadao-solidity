# VaultOwned
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/704b462e69030cb9a43680057bee91d745d579ba/src/protocol/tokens/regular/KlimaToken.sol)

**Inherits:**
[Ownable](/src/protocol/staking/regular/KlimaStaking_v2.sol/contract.Ownable.md)


## State Variables
### _vault

```solidity
address internal _vault;
```


## Functions
### setVault


```solidity
function setVault(address vault_) external onlyOwner returns (bool);
```

### vault

*Returns the address of the current vault.*


```solidity
function vault() public view returns (address);
```

### onlyVault

*Throws if called by any account other than the vault.*


```solidity
modifier onlyVault();
```

