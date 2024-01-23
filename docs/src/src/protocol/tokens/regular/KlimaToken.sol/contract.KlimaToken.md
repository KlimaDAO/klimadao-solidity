# KlimaToken
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/tokens/regular/KlimaToken.sol)

**Inherits:**
[Divine](/src/protocol/tokens/regular/KlimaToken.sol/contract.Divine.md)


## Functions
### constructor


```solidity
constructor() Divine("Klima DAO", "KLIMA", 9);
```

### mint


```solidity
function mint(address account_, uint amount_) external onlyVault;
```

### burn

*Destroys `amount` tokens from the caller.
See {ERC20-_burn}.*


```solidity
function burn(uint amount) public virtual;
```

### burnFrom


```solidity
function burnFrom(address account_, uint amount_) public virtual;
```

### _burnFrom


```solidity
function _burnFrom(address account_, uint amount_) public virtual;
```

