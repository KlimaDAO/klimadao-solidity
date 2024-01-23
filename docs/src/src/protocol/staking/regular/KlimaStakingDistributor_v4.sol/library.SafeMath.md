# SafeMath
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/staking/regular/KlimaStakingDistributor_v4.sol)


## Functions
### add


```solidity
function add(uint a, uint b) internal pure returns (uint);
```

### sub


```solidity
function sub(uint a, uint b) internal pure returns (uint);
```

### sub


```solidity
function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint);
```

### mul


```solidity
function mul(uint a, uint b) internal pure returns (uint);
```

### div


```solidity
function div(uint a, uint b) internal pure returns (uint);
```

### div


```solidity
function div(uint a, uint b, string memory errorMessage) internal pure returns (uint);
```

### mod


```solidity
function mod(uint a, uint b) internal pure returns (uint);
```

### mod


```solidity
function mod(uint a, uint b, string memory errorMessage) internal pure returns (uint);
```

### sqrrt


```solidity
function sqrrt(uint a) internal pure returns (uint c);
```

### percentageAmount


```solidity
function percentageAmount(uint total_, uint8 percentage_) internal pure returns (uint percentAmount_);
```

### substractPercentage


```solidity
function substractPercentage(uint total_, uint8 percentageToSub_) internal pure returns (uint result_);
```

### percentageOfTotal


```solidity
function percentageOfTotal(uint part_, uint total_) internal pure returns (uint percent_);
```

### average


```solidity
function average(uint a, uint b) internal pure returns (uint);
```

### quadraticPricing


```solidity
function quadraticPricing(uint payment_, uint multiplier_) internal pure returns (uint);
```

### bondingCurve


```solidity
function bondingCurve(uint supply_, uint multiplier_) internal pure returns (uint);
```

