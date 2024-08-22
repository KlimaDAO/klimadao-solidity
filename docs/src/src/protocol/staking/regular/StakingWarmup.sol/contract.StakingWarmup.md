# StakingWarmup
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/protocol/staking/regular/StakingWarmup.sol)


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

