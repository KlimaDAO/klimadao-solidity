# Ownable
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/protocol/tokens/regular/sKlimaToken.sol)

**Inherits:**
[IOwnable](/src/protocol/staking/utils/KlimaTreasury.sol/interface.IOwnable.md)


## State Variables
### _owner

```solidity
address internal _owner;
```


## Functions
### constructor

*Initializes the contract setting the deployer as the initial owner.*


```solidity
constructor();
```

### owner

*Returns the address of the current owner.*


```solidity
function owner() public view override returns (address);
```

### onlyOwner

*Throws if called by any account other than the owner.*


```solidity
modifier onlyOwner();
```

### renounceOwnership

*Leaves the contract without owner. It will not be possible to call
`onlyOwner` functions anymore. Can only be called by the current owner.
NOTE: Renouncing ownership will leave the contract without an owner,
thereby removing any functionality that is only available to the owner.*


```solidity
function renounceOwnership() public virtual override onlyOwner;
```

### transferOwnership

*Transfers ownership of the contract to a new account (`newOwner`).
Can only be called by the current owner.*


```solidity
function transferOwnership(address newOwner_) public virtual override onlyOwner;
```

## Events
### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
```

