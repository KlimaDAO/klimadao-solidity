# KlimaToken
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/protocol/tokens/regular/KlimaToken.sol)

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
See [ERC20-_burn](/lib/openzeppelin-contracts-4-5-0/contracts/token/ERC1155/ERC1155.sol/contract.ERC1155.md#_burn).*


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

