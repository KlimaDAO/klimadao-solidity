# IC3Pool
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/retirement_v1/interfaces/IC3Pool.sol)


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

