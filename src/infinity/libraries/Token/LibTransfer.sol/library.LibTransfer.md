# LibTransfer
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/infinity/libraries/Token/LibTransfer.sol)

**Author:**
publius


## Functions
### transferToken


```solidity
function transferToken(IERC20 token, address recipient, uint256 amount, From fromMode, To toMode)
    internal
    returns (uint256 transferredAmount);
```

### receiveToken


```solidity
function receiveToken(IERC20 token, uint256 amount, address sender, From mode)
    internal
    returns (uint256 receivedAmount);
```

### receive1155Token


```solidity
function receive1155Token(IERC1155 token, uint256 tokenId, uint256 amount, address sender, From mode)
    internal
    returns (uint256 receivedAmount);
```

### sendToken


```solidity
function sendToken(IERC20 token, uint256 amount, address recipient, To mode) internal;
```

## Enums
### From

```solidity
enum From {
    EXTERNAL,
    INTERNAL,
    EXTERNAL_INTERNAL,
    INTERNAL_TOLERANT
}
```

### To

```solidity
enum To {
    EXTERNAL,
    INTERNAL
}
```

