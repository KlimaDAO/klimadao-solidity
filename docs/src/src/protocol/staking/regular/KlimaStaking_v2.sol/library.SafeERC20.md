# SafeERC20
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/704b462e69030cb9a43680057bee91d745d579ba/src/protocol/staking/regular/KlimaStaking_v2.sol)


## Functions
### safeTransfer


```solidity
function safeTransfer(IERC20 token, address to, uint256 value) internal;
```

### safeTransferFrom


```solidity
function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal;
```

### safeApprove

*Deprecated. This function has issues similar to the ones found in
{IERC20-approve}, and its usage is discouraged.
Whenever possible, use {safeIncreaseAllowance} and
{safeDecreaseAllowance} instead.*


```solidity
function safeApprove(IERC20 token, address spender, uint256 value) internal;
```

### safeIncreaseAllowance


```solidity
function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal;
```

### safeDecreaseAllowance


```solidity
function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal;
```

### _callOptionalReturn

*Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
on the return value: the return value is optional (but if data is returned, it must not be false).*


```solidity
function _callOptionalReturn(IERC20 token, bytes memory data) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`IERC20`|The token targeted by the call.|
|`data`|`bytes`|The call data (encoded using abi.encode or one of its variants).|


