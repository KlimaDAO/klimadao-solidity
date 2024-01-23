# IToucanPool
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/retirement_v1/interfaces/IToucanPool.sol)


## Functions
### redeemAuto2


```solidity
function redeemAuto2(uint amount) external returns (address[] memory tco2s, uint[] memory amounts);
```

### redeemMany


```solidity
function redeemMany(address[] calldata erc20s, uint[] calldata amounts) external;
```

### feeRedeemPercentageInBase


```solidity
function feeRedeemPercentageInBase() external pure returns (uint);
```

### feeRedeemDivider


```solidity
function feeRedeemDivider() external pure returns (uint);
```

### redeemFeeExemptedAddresses


```solidity
function redeemFeeExemptedAddresses(address) external view returns (bool);
```

