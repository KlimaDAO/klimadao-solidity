# StakingWarmup
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/protocol/staking/regular/StakingWarmup.sol)


## State Variables
### staking

```solidity
address public immutable staking;
```


### sKLIMA

```solidity
address public immutable sKLIMA;
```


## Functions
### constructor


```solidity
constructor(address _staking, address _sKLIMA);
```

### retrieve


```solidity
function retrieve(address _staker, uint256 _amount) external;
```

