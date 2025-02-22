# RetireToucanTCO2Facet
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/infinity/facets/Bridges/Toucan/RetireToucanTCO2Facet.sol)

**Inherits:**
[ReentrancyGuard](/src/infinity/ReentrancyGuard.sol/abstract.ReentrancyGuard.md)


## Functions
### toucanRetireExactTCO2

This contract assumes that the token being provided is a raw TCO2 token.

The transactions will revert otherwise

Redeems TCO2 directly


```solidity
function toucanRetireExactTCO2(
    address carbonToken,
    uint256 amount,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    LibTransfer.From fromMode
) external nonReentrant returns (uint256 retirementIndex);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`carbonToken`|`address`|         Pool token to redeem|
|`amount`|`uint256`|              Amounts of underlying tokens to redeem|
|`beneficiaryAddress`|`address`|  0x address for the beneficiary|
|`beneficiaryString`|`string`|   String description of the beneficiary|
|`retirementMessage`|`string`|   String message for this specific retirement|
|`fromMode`|`LibTransfer.From`|            From Mode for transfering tokens|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`retirementIndex`|`uint256`|    The latest retirement index for the beneficiary address|


### toucanRetireExactTCO2WithEntity

Redeems TCO2 directly


```solidity
function toucanRetireExactTCO2WithEntity(
    address carbonToken,
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
|`carbonToken`|`address`|         Pool token to redeem|
|`amount`|`uint256`|              Amounts of underlying tokens to redeem|
|`retiringEntityString`|`string`|String description of the retiring entity|
|`beneficiaryAddress`|`address`|  0x address for the beneficiary|
|`beneficiaryString`|`string`|   String description of the beneficiary|
|`retirementMessage`|`string`|   String message for this specific retirement|
|`fromMode`|`LibTransfer.From`|            From Mode for transfering tokens|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`retirementIndex`|`uint256`|    The latest retirement index for the beneficiary address|


### toucanRetireExactPuroTCO2

Retires Puro TCO2 directly


```solidity
function toucanRetireExactPuroTCO2(
    address projectToken,
    uint256 tokenId,
    uint256 amount,
    LibRetire.RetireDetails memory details,
    LibTransfer.From fromMode
) external nonReentrant returns (uint256 retirementIndex);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`projectToken`|`address`|        Puro token to retire|
|`tokenId`|`uint256`|             Token ID being retired|
|`amount`|`uint256`|              Amounts of underlying tokens to redeem|
|`details`|`LibRetire.RetireDetails`|             Encoded struct of retirement details needed for the request|
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
    uint256 retiredAmount
);
```

