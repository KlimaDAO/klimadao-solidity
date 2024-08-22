# LibICRCarbon
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/infinity/libraries/Bridges/LibICRCarbon.sol)

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

