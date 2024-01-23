# StakingWarmup
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/protocol/staking/regular/StakingWarmup.sol)


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

