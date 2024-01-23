# SafeMath
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/protocol/staking/regular/KlimaStakingDistributor_v4.sol)


## Functions
### add


```solidity
function add(uint256 a, uint256 b) internal pure returns (uint256);
```

### sub


```solidity
function sub(uint256 a, uint256 b) internal pure returns (uint256);
```

### sub


```solidity
function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256);
```

### mul


```solidity
function mul(uint256 a, uint256 b) internal pure returns (uint256);
```

### div


```solidity
function div(uint256 a, uint256 b) internal pure returns (uint256);
```

### div


```solidity
function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256);
```

### mod


```solidity
function mod(uint256 a, uint256 b) internal pure returns (uint256);
```

### mod


```solidity
function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256);
```

### sqrrt


```solidity
function sqrrt(uint256 a) internal pure returns (uint256 c);
```

### percentageAmount


```solidity
function percentageAmount(uint256 total_, uint8 percentage_) internal pure returns (uint256 percentAmount_);
```

### substractPercentage


```solidity
function substractPercentage(uint256 total_, uint8 percentageToSub_) internal pure returns (uint256 result_);
```

### percentageOfTotal


```solidity
function percentageOfTotal(uint256 part_, uint256 total_) internal pure returns (uint256 percent_);
```

### average


```solidity
function average(uint256 a, uint256 b) internal pure returns (uint256);
```

### quadraticPricing


```solidity
function quadraticPricing(uint256 payment_, uint256 multiplier_) internal pure returns (uint256);
```

### bondingCurve


```solidity
function bondingCurve(uint256 supply_, uint256 multiplier_) internal pure returns (uint256);
```

