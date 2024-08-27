# IC3Pool
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/infinity/interfaces/IC3.sol)


## Functions
### freeRedeem


```solidity
function freeRedeem(uint256 amount) external;
```

### taxedRedeem


```solidity
function taxedRedeem(address[] memory erc20Addresses, uint256[] memory amount) external;
```

### getFreeRedeemAddresses


```solidity
function getFreeRedeemAddresses() external view returns (address[] memory);
```

### getERC20Tokens


```solidity
function getERC20Tokens() external view returns (address[] memory);
```

### feeRedeem


```solidity
function feeRedeem() external view returns (uint256);
```

