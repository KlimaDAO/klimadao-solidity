# IC3Pool
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/retirement_v1/interfaces/IC3Pool.sol)


## Functions
### freeRedeem


```solidity
function freeRedeem(uint amount) external;
```

### taxedRedeem


```solidity
function taxedRedeem(address[] memory erc20Addresses, uint[] memory amount) external;
```

### getFreeRedeemAddresses


```solidity
function getFreeRedeemAddresses() external view returns (address[] memory);
```

### feeRedeem


```solidity
function feeRedeem() external view returns (uint);
```

