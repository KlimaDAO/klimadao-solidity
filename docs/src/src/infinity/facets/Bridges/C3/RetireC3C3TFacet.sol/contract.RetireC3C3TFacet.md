# RetireC3C3TFacet
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/infinity/facets/Bridges/C3/RetireC3C3TFacet.sol)

**Inherits:**
[ReentrancyGuard](/src/infinity/ReentrancyGuard.sol/abstract.ReentrancyGuard.md)


## Functions
### c3RetireExactC3T

This contract assumes that the token being provided is a raw TCO2 token.

The transactions will revert otherwise.

Redeems C3T directly


```solidity
function c3RetireExactC3T(
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


### c3RetireExactC3TWithEntity

Redeems C3T directly


```solidity
function c3RetireExactC3TWithEntity(
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

