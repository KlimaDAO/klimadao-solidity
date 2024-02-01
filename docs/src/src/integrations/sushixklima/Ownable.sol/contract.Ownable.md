# Ownable
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/integrations/sushixklima/Ownable.sol)

**Inherits:**
[IOwnable](/src/protocol/tokens/regular/sKlimaToken_v2.sol/interface.IOwnable.md)


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
