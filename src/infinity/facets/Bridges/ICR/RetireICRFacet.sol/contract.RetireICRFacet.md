# RetireICRFacet
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/infinity/facets/Bridges/ICR/RetireICRFacet.sol)

**Inherits:**
[ReentrancyGuard](/src/infinity/ReentrancyGuard.sol/abstract.ReentrancyGuard.md)


## Functions
### icrRetireExactCarbon

This contract assumes that the token being provided is a raw ICR project token.

The transactions will revert otherwise.

Redeems ICR credit directly


```solidity
function icrRetireExactCarbon(
    address projectToken,
    uint256 tokenId,
    uint256 amount,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    LibTransfer.From fromMode
) external nonReentrant returns (uint256 retirementIndex);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`projectToken`|`address`|        Project token address|
|`tokenId`|`uint256`|             Token ID for project to retire|
|`amount`|`uint256`|              Amounts of underlying tokens to redeem|
|`retiringEntityString`|`string`|String description for the retiring entity|
|`beneficiaryAddress`|`address`|  0x address for the beneficiary|
|`beneficiaryString`|`string`|   String description of the beneficiary|
|`retirementMessage`|`string`|   String message for this specific retirement|
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
    address carbonToken,
    uint256 tokenId,
    uint256 retiredAmount
);
```

