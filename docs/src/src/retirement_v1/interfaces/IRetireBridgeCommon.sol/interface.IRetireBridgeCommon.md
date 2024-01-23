# IRetireBridgeCommon
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/retirement_v1/interfaces/IRetireBridgeCommon.sol)


## Functions
### getNeededBuyAmount


```solidity
function getNeededBuyAmount(address _sourceToken, address _poolToken, uint _poolAmount, bool _retireSpecific)
    external
    view
    returns (uint, uint);
```

### getSwapPath


```solidity
function getSwapPath(address _sourceToken, address _poolToken) external view returns (address[] memory);
```

### poolRouter


```solidity
function poolRouter(address _poolToken) external view returns (address);
```

