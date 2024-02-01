# VaultOwned
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/protocol/tokens/regular/KlimaToken.sol)

**Inherits:**
[Ownable](/src/protocol/tokens/regular/sKlimaToken_v2.sol/contract.Ownable.md)


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

