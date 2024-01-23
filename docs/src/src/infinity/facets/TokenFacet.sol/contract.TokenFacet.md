# TokenFacet
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/facets/TokenFacet.sol)

**Author:**
Publius

SPDX-License-Identifier: MIT


## Functions
### transferToken

Transfer


```solidity
function transferToken(IERC20 token, address recipient, uint amount, LibTransfer.From fromMode, LibTransfer.To toMode)
    external
    payable;
```

### wrapMatic

Weth


```solidity
function wrapMatic(uint amount, LibTransfer.To mode) external payable;
```

### unwrapMatic


```solidity
function unwrapMatic(uint amount, LibTransfer.From mode) external payable;
```

### getInternalBalance

Getters


```solidity
function getInternalBalance(address account, IERC20 token) public view returns (uint balance);
```

### getInternalBalances


```solidity
function getInternalBalances(address account, IERC20[] memory tokens) external view returns (uint[] memory balances);
```

### getExternalBalance


```solidity
function getExternalBalance(address account, IERC20 token) public view returns (uint balance);
```

### getExternalBalances


```solidity
function getExternalBalances(address account, IERC20[] memory tokens) external view returns (uint[] memory balances);
```

### getBalance


```solidity
function getBalance(address account, IERC20 token) public view returns (uint balance);
```

### getBalances


```solidity
function getBalances(address account, IERC20[] memory tokens) external view returns (uint[] memory balances);
```

### getAllBalance


```solidity
function getAllBalance(address account, IERC20 token) public view returns (Balance memory b);
```

### getAllBalances


```solidity
function getAllBalances(address account, IERC20[] memory tokens) external view returns (Balance[] memory balances);
```

## Events
### InternalBalanceChanged

```solidity
event InternalBalanceChanged(address indexed user, IERC20 indexed token, int delta);
```

## Structs
### Balance

```solidity
struct Balance {
    uint internalBalance;
    uint externalBalance;
    uint totalBalance;
}
```

