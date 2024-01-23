# RetireC3C3TFacet
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/facets/Bridges/C3/RetireC3C3TFacet.sol)

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
    uint amount,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    LibTransfer.From fromMode
) external nonReentrant returns (uint retirementIndex);
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
    uint amount,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    LibTransfer.From fromMode
) external nonReentrant returns (uint retirementIndex);
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
    uint retiredAmount
);
```

