# LibBalance
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/29fd912e7e35bfd36ad9c6e57c2a312d3aed3640/src/infinity/libraries/Token/LibBalance.sol)

**Author:**
LeoFib, Publius


## Functions
### getBalance


```solidity
function getBalance(address account, IERC20 token) internal view returns (uint256 combined_balance);
```

### increaseInternalBalance

*Increases `account`'s Internal Balance for `token` by `amount`.*


```solidity
function increaseInternalBalance(address account, IERC20 token, uint256 amount) internal;
```

### decreaseInternalBalance

*Decreases `account`'s Internal Balance for `token` by `amount`. If `allowPartial` is true, this function
doesn't revert if `account` doesn't have enough balance, and sets it to zero and returns the deducted amount
instead.*


```solidity
function decreaseInternalBalance(address account, IERC20 token, uint256 amount, bool allowPartial)
    internal
    returns (uint256 deducted);
```

### setInternalBalance

*Sets `account`'s Internal Balance for `token` to `newBalance`.
Emits an `InternalBalanceChanged` event. This event includes `delta`, which is the amount the balance increased
(if positive) or decreased (if negative). To avoid reading the current balance in order to compute the delta,
this function relies on the caller providing it directly.*


```solidity
function setInternalBalance(address account, IERC20 token, uint256 newBalance, int256 delta) private;
```

### getInternalBalance

*Returns `account`'s Internal Balance for `token`.*


```solidity
function getInternalBalance(address account, IERC20 token) internal view returns (uint256);
```

## Events
### InternalBalanceChanged
*Emitted when a account's Internal Balance changes, through interacting using Internal Balance.*


```solidity
event InternalBalanceChanged(address indexed account, IERC20 indexed token, int256 delta);
```

