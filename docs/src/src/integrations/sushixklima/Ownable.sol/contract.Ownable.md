# Ownable
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/704b462e69030cb9a43680057bee91d745d579ba/src/integrations/sushixklima/Ownable.sol)

**Inherits:**
[IOwnable](/src/protocol/staking/regular/KlimaStaking_v2.sol/interface.IOwnable.md)


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

