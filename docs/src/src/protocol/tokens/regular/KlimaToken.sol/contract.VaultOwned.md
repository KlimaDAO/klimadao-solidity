# VaultOwned
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/protocol/tokens/regular/KlimaToken.sol)

**Inherits:**
[Ownable](/src/protocol/staking/utils/KlimaTreasury.sol/contract.Ownable.md)


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

