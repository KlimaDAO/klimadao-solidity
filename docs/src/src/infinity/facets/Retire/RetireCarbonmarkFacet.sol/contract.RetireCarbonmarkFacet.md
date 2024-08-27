# RetireCarbonmarkFacet
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/infinity/facets/Retire/RetireCarbonmarkFacet.sol)

**Inherits:**
[ReentrancyGuard](/src/infinity/ReentrancyGuard.sol/abstract.ReentrancyGuard.md)


## Functions
### retireCarbonmarkListing

Retires an exact amount of carbon using default redemption


```solidity
function retireCarbonmarkListing(
    ICarbonmark.CreditListing memory listing,
    uint256 maxAmountIn,
    uint256 retireAmount,
    LibRetire.RetireDetails memory details,
    LibTransfer.From fromMode
) external payable nonReentrant returns (uint256 retirementIndex);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`listing`|`ICarbonmark.CreditListing`||
|`maxAmountIn`|`uint256`|         Maximum amount of USDC tokens to spend for this retirement|
|`retireAmount`|`uint256`|        The amount of carbon to retire|
|`details`|`LibRetire.RetireDetails`|             Encoded struct of retirement details needed for the retirement|
|`fromMode`|`LibTransfer.From`|            From Mode for transfering tokens|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`retirementIndex`|`uint256`|    The latest retirement index for the beneficiary address|


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
    address poolToken,
    uint256 retiredAmount
);
```

