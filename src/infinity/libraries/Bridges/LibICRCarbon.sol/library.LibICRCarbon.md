# LibICRCarbon
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/infinity/libraries/Bridges/LibICRCarbon.sol)

**Author:**
Cujo


## Functions
### retireICC


```solidity
function retireICC(
    address poolToken,
    address projectToken,
    uint256 tokenId,
    uint256 amount,
    LibRetire.RetireDetails memory details
) internal returns (uint256 retiredAmount);
```

### isValid


```solidity
function isValid(address token) internal view returns (bool);
```

## Events
### CarbonRetired

```solidity
event CarbonRetired(
    LibRetire.CarbonBridge carbonBridge,
    address indexed retiringAddress,
    string retiringEntityString,
    address indexed beneficiaryAddress,
    string beneficiaryString,
    string retirementMessage,
    address indexed carbonPool,
    address carbonToken,
    uint256 tokenId,
    uint256 retiredAmount
);
```

