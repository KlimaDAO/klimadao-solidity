# StakingWarmup
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/staking/regular/StakingWarmup.sol)


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
function retrieve(address _staker, uint _amount) external;
```

