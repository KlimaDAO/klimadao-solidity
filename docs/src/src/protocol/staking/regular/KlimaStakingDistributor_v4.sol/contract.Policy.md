# Policy
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/staking/regular/KlimaStakingDistributor_v4.sol)

**Inherits:**
[IPolicy](/src/protocol/staking/regular/KlimaStakingDistributor_v4.sol/interface.IPolicy.md)


## State Variables
### _policy

```solidity
address internal _policy;
```


### _newPolicy

```solidity
address internal _newPolicy;
```


## Functions
### constructor


```solidity
constructor();
```

### policy


```solidity
function policy() public view override returns (address);
```

### onlyPolicy


```solidity
modifier onlyPolicy();
```

### renouncePolicy


```solidity
function renouncePolicy() public virtual override onlyPolicy;
```

### pushPolicy


```solidity
function pushPolicy(address newPolicy_) public virtual override onlyPolicy;
```

### pullPolicy


```solidity
function pullPolicy() public virtual override;
```

## Events
### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
```

