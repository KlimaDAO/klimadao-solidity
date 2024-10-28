# Ownable
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/protocol/staking/utils/KlimaTreasury.sol)

**Inherits:**
[IOwnable](/src/protocol/staking/utils/KlimaTreasury.sol/interface.IOwnable.md)


## State Variables
### _owner

```solidity
address internal _owner;
```


### _newOwner

```solidity
address internal _newOwner;
```


## Functions
### constructor


```solidity
constructor();
```

### manager


```solidity
function manager() public view override returns (address);
```

### onlyManager


```solidity
modifier onlyManager();
```

### renounceManagement


```solidity
function renounceManagement() public virtual override onlyManager;
```

### pushManagement


```solidity
function pushManagement(address newOwner_) public virtual override onlyManager;
```

### pullManagement


```solidity
function pullManagement() public virtual override;
```

## Events
### OwnershipPushed

```solidity
event OwnershipPushed(address indexed previousOwner, address indexed newOwner);
```

### OwnershipPulled

```solidity
event OwnershipPulled(address indexed previousOwner, address indexed newOwner);
```

