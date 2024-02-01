# KlimaToken
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/protocol/tokens/regular/KlimaToken.sol)

**Inherits:**
[Divine](/src/protocol/tokens/regular/KlimaToken.sol/contract.Divine.md)


## Functions
### constructor


```solidity
constructor() Divine("Klima DAO", "KLIMA", 9);
```

### mint


```solidity
function mint(address account_, uint256 amount_) external onlyVault;
```

### burn

*Destroys `amount` tokens from the caller.
See {ERC20-_burn}.*


```solidity
function burn(uint256 amount) public virtual;
```

### burnFrom


```solidity
function burnFrom(address account_, uint256 amount_) public virtual;
```

### _burnFrom


```solidity
function _burnFrom(address account_, uint256 amount_) public virtual;
```

