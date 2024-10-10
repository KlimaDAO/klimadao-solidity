# RetireSourceFacet
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/infinity/facets/Retire/RetireSourceFacet.sol)

**Inherits:**
[ReentrancyGuard](/src/infinity/ReentrancyGuard.sol/abstract.ReentrancyGuard.md)


## Functions
### retireExactSourceDefault

Retires an exact amount of a source token using default redemption


```solidity
function retireExactSourceDefault(
    address sourceToken,
    address poolToken,
    uint256 maxAmountIn,
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
|`sourceToken`|`address`|         Source ERC-20 token to use for the retirement|
|`poolToken`|`address`|           Pool token to use for this retirement|
|`maxAmountIn`|`uint256`|         Maximum amount of source tokens to spend in this retirement|
|`retiringEntityString`|`string`|String description of the retiring entity|
|`beneficiaryAddress`|`address`|  0x address for the beneficiary|
|`beneficiaryString`|`string`|   String description of the beneficiary|
|`retirementMessage`|`string`|   String message for this specific retirement|
|`fromMode`|`LibTransfer.From`|            From Mode for transfering tokens|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`retirementIndex`|`uint256`|    The latest retirement index for the beneficiary address|


### retireExactSourceSpecific

Retires an exact amount of a source token using specific redemption

*Initial value set assuming source == pool.*


```solidity
function retireExactSourceSpecific(
    address sourceToken,
    address poolToken,
    address projectToken,
    uint256 maxAmountIn,
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
|`sourceToken`|`address`|         Source ERC-20 token to use for the retirement|
|`poolToken`|`address`|           Pool token to use for this retirement|
|`projectToken`|`address`|        Project token to redeem and retire|
|`maxAmountIn`|`uint256`|         Maximum amount of source tokens to spend in this retirement|
|`retiringEntityString`|`string`|String description of the retiring entity|
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
    address poolToken,
    uint256 retiredAmount
);
```

