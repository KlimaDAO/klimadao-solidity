# IERC20
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/staking/regular/KlimaStakingDistributor_v4.sol)


## Functions
### totalSupply


```solidity
function totalSupply() external view returns (uint);
```

### balanceOf


```solidity
function balanceOf(address account) external view returns (uint);
```

### transfer


```solidity
function transfer(address recipient, uint amount) external returns (bool);
```

### allowance


```solidity
function allowance(address owner, address spender) external view returns (uint);
```

### approve


```solidity
function approve(address spender, uint amount) external returns (bool);
```

### transferFrom


```solidity
function transferFrom(address sender, address recipient, uint amount) external returns (bool);
```

## Events
### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint value);
```

### Approval

```solidity
event Approval(address indexed owner, address indexed spender, uint value);
```

