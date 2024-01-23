# Ownable
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/protocol/tokens/regular/KlimaToken.sol)

**Inherits:**
[IOwnable](/src/integrations/sushixklima/Ownable.sol/interface.IOwnable.md)


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

