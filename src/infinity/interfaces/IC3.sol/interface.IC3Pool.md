# IC3Pool
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/infinity/interfaces/IC3.sol)


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

