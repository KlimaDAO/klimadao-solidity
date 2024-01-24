# StakingHelper
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/29fd912e7e35bfd36ad9c6e57c2a312d3aed3640/src/protocol/staking/regular/StakingHelper.sol)


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

