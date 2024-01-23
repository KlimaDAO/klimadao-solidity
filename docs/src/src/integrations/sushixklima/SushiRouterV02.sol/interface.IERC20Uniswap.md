# IERC20Uniswap
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/integrations/sushixklima/SushiRouterV02.sol)


## Functions
### name


```solidity
function name() external view returns (string memory);
```

### symbol


```solidity
function symbol() external view returns (string memory);
```

### decimals


```solidity
function decimals() external view returns (uint8);
```

### totalSupply


```solidity
function totalSupply() external view returns (uint);
```

### balanceOf


```solidity
function balanceOf(address owner) external view returns (uint);
```

### allowance


```solidity
function allowance(address owner, address spender) external view returns (uint);
```

### approve


```solidity
function approve(address spender, uint value) external returns (bool);
```

### transfer


```solidity
function transfer(address to, uint value) external returns (bool);
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint value) external returns (bool);
```

## Events
### Approval

```solidity
event Approval(address indexed owner, address indexed spender, uint value);
```

### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint value);
```

