# IToucanPool
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/retirement_v1/interfaces/IToucanPool.sol)


## Functions
### redeemAuto2


```solidity
function redeemAuto2(uint256 amount) external returns (address[] memory tco2s, uint256[] memory amounts);
```

### redeemMany


```solidity
function redeemMany(address[] calldata erc20s, uint256[] calldata amounts) external;
```

### feeRedeemPercentageInBase


```solidity
function feeRedeemPercentageInBase() external pure returns (uint256);
```

### feeRedeemDivider


```solidity
function feeRedeemDivider() external pure returns (uint256);
```

### redeemFeeExemptedAddresses


```solidity
function redeemFeeExemptedAddresses(address) external view returns (bool);
```

