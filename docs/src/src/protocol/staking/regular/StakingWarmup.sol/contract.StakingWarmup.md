# StakingWarmup
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/704b462e69030cb9a43680057bee91d745d579ba/src/protocol/staking/regular/StakingWarmup.sol)


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

