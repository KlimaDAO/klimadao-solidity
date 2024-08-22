# IToucanPool
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/infinity/interfaces/IToucan.sol)


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

### getScoredTCO2s


```solidity
function getScoredTCO2s() external view returns (address[] memory);
```

