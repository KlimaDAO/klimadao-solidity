# LibTransfer
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/libraries/Token/LibTransfer.sol)

**Author:**
publius


## Functions
### transferToken


```solidity
function transferToken(IERC20 token, address recipient, uint amount, From fromMode, To toMode)
    internal
    returns (uint transferredAmount);
```

### receiveToken


```solidity
function receiveToken(IERC20 token, uint amount, address sender, From mode) internal returns (uint receivedAmount);
```

### sendToken


```solidity
function sendToken(IERC20 token, uint amount, address recipient, To mode) internal;
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

