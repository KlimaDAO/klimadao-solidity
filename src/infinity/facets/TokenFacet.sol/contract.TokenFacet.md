# TokenFacet
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/infinity/facets/TokenFacet.sol)

**Author:**
Publius

SPDX-License-Identifier: MIT


## Functions
### transferToken

Transfer


```solidity
function transferToken(
    IERC20 token,
    address recipient,
    uint256 amount,
    LibTransfer.From fromMode,
    LibTransfer.To toMode
) external payable;
```

### wrapMatic

Weth


```solidity
function wrapMatic(uint256 amount, LibTransfer.To mode) external payable;
```

### unwrapMatic


```solidity
function unwrapMatic(uint256 amount, LibTransfer.From mode) external payable;
```

### getInternalBalance

Getters


```solidity
function getInternalBalance(address account, IERC20 token) public view returns (uint256 balance);
```

### getInternalBalances


```solidity
function getInternalBalances(address account, IERC20[] memory tokens)
    external
    view
    returns (uint256[] memory balances);
```

### getExternalBalance


```solidity
function getExternalBalance(address account, IERC20 token) public view returns (uint256 balance);
```

### getExternalBalances


```solidity
function getExternalBalances(address account, IERC20[] memory tokens)
    external
    view
    returns (uint256[] memory balances);
```

### getBalance


```solidity
function getBalance(address account, IERC20 token) public view returns (uint256 balance);
```

### getBalances


```solidity
function getBalances(address account, IERC20[] memory tokens) external view returns (uint256[] memory balances);
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
event InternalBalanceChanged(address indexed user, IERC20 indexed token, int256 delta);
```

## Structs
### Balance

```solidity
struct Balance {
    uint256 internalBalance;
    uint256 externalBalance;
    uint256 totalBalance;
}
```

