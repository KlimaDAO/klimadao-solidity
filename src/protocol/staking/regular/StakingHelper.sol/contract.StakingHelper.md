# StakingHelper
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/protocol/staking/regular/StakingHelper.sol)


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

