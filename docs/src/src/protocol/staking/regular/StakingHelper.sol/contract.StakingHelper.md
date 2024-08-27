# StakingHelper
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/protocol/staking/regular/StakingHelper.sol)


## State Variables
### staking

```solidity
address public immutable staking;
```


### KLIMA

```solidity
address public immutable KLIMA;
```


## Functions
### constructor


```solidity
constructor(address _staking, address _KLIMA);
```

### stake


```solidity
function stake(uint256 _amount) external;
```

