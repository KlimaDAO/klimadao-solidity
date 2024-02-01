# RetireCarbonmarkFacet
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/infinity/facets/Retire/RetireCarbonmarkFacet.sol)

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
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    LibTransfer.From fromMode
) external payable nonReentrant returns (uint256 retirementIndex);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`listing`|`CreditListing.ICarbonmark`||
|`maxAmountIn`|`uint256`|         Maximum amount of USDC tokens to spend for this retirement|
|`retireAmount`|`uint256`|        The amount of carbon to retire|
|`retiringEntityString`|`string`|String description of the retiring entity|
|`beneficiaryAddress`|`address`|  0x address for the beneficiary|
|`beneficiaryString`|`string`|   String description of the beneficiary|
|`retirementMessage`|`string`|   String message for this specific retirement|
|`fromMode`|`From.LibTransfer`|            From Mode for transfering tokens|

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

