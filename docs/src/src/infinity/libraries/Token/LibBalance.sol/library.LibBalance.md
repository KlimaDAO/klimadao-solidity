# LibBalance
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/libraries/Token/LibBalance.sol)

**Author:**
LeoFib, Publius


## Functions
### getBalance


```solidity
function getBalance(address account, IERC20 token) internal view returns (uint combined_balance);
```

### increaseInternalBalance

*Increases `account`'s Internal Balance for `token` by `amount`.*


```solidity
function increaseInternalBalance(address account, IERC20 token, uint amount) internal;
```

### decreaseInternalBalance

*Decreases `account`'s Internal Balance for `token` by `amount`. If `allowPartial` is true, this function
doesn't revert if `account` doesn't have enough balance, and sets it to zero and returns the deducted amount
instead.*


```solidity
function decreaseInternalBalance(address account, IERC20 token, uint amount, bool allowPartial)
    internal
    returns (uint deducted);
```

### setInternalBalance

*Sets `account`'s Internal Balance for `token` to `newBalance`.
Emits an `InternalBalanceChanged` event. This event includes `delta`, which is the amount the balance increased
(if positive) or decreased (if negative). To avoid reading the current balance in order to compute the delta,
this function relies on the caller providing it directly.*


```solidity
function setInternalBalance(address account, IERC20 token, uint newBalance, int delta) private;
```

### getInternalBalance

*Returns `account`'s Internal Balance for `token`.*


```solidity
function getInternalBalance(address account, IERC20 token) internal view returns (uint);
```

## Events
### InternalBalanceChanged
*Emitted when a account's Internal Balance changes, through interacting using Internal Balance.*


```solidity
event InternalBalanceChanged(address indexed account, IERC20 indexed token, int delta);
```

