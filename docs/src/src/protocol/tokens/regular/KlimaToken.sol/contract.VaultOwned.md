# VaultOwned
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/protocol/tokens/regular/KlimaToken.sol)

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

