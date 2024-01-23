# IRetireBridgeCommon
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/retirement_v1/interfaces/IRetireBridgeCommon.sol)


## Functions
### getNeededBuyAmount


```solidity
function getNeededBuyAmount(address _sourceToken, address _poolToken, uint256 _poolAmount, bool _retireSpecific)
    external
    view
    returns (uint256, uint256);
```

### getSwapPath


```solidity
function getSwapPath(address _sourceToken, address _poolToken) external view returns (address[] memory);
```

### poolRouter


```solidity
function poolRouter(address _poolToken) external view returns (address);
```

