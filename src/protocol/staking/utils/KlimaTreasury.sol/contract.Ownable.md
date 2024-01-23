# Ownable
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/protocol/staking/utils/KlimaTreasury.sol)

**Inherits:**
[IOwnable](/src/integrations/sushixklima/Ownable.sol/interface.IOwnable.md)


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

