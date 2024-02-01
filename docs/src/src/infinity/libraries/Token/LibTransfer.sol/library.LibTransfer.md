# LibTransfer
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/infinity/libraries/Token/LibTransfer.sol)

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

