# IC3Pool
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/retirement_v1/interfaces/IC3Pool.sol)


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

### feeRedeem


```solidity
function feeRedeem() external view returns (uint256);
```

