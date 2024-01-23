# SafeERC20
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/staking/regular/KlimaStakingDistributor_v4.sol)


## Functions
### safeTransfer


```solidity
function safeTransfer(IERC20 token, address to, uint value) internal;
```

### safeTransferFrom


```solidity
function safeTransferFrom(IERC20 token, address from, address to, uint value) internal;
```

### safeApprove


```solidity
function safeApprove(IERC20 token, address spender, uint value) internal;
```

### safeIncreaseAllowance


```solidity
function safeIncreaseAllowance(IERC20 token, address spender, uint value) internal;
```

### safeDecreaseAllowance


```solidity
function safeDecreaseAllowance(IERC20 token, address spender, uint value) internal;
```

### _callOptionalReturn


```solidity
function _callOptionalReturn(IERC20 token, bytes memory data) private;
```

