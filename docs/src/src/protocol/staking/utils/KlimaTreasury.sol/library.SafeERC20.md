# SafeERC20
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/704b462e69030cb9a43680057bee91d745d579ba/src/protocol/staking/utils/KlimaTreasury.sol)


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


```solidity
function _callOptionalReturn(IERC20 token, bytes memory data) private;
```

