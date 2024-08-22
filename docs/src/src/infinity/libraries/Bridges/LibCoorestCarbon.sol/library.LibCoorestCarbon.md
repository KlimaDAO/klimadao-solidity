# LibCoorestCarbon
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/infinity/libraries/Bridges/LibCoorestCarbon.sol)

**Author:**
must-be-carbon

Handles interaction with the Coorest Pool and child tokens ( CCO2, POCC )


## Functions
### retireCarbonToken

Retires CCO2

*Use this function to retire CCO2.*

*This function assumes that checks to carbonToken are make higher up in call stack.*

*It's important to know that Coorest transfers fee portion to it's account & rest amount is burned*


```solidity
function retireCarbonToken(
    address carbonToken,
    uint256 retireAmount,
    uint256 retireAmountWithFee,
    LibRetire.RetireDetails memory details
) internal returns (uint256 poccId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`carbonToken`|`address`|CCO2 token address.|
|`retireAmount`|`uint256`|The amount of underlying tokens to retire.|
|`retireAmountWithFee`|`uint256`||
|`details`|`LibRetire.RetireDetails`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`poccId`|`uint256`|POCC Certificate Id.|


### getSpecificRetirementFee

Calculates the Coorest fee that needs to be added to desired retire amount

*Use this function to compute the Coorest fee.*

*This function assumes that checks to carbonToken are make higher up in call stack*


```solidity
function getSpecificRetirementFee(address carbonToken, uint256 amount) public view returns (uint256 feeAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`carbonToken`|`address`|    CCO2 token address|
|`amount`|`uint256`|         The amount of underlying tokens to retire.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`feeAmount`|`uint256`|     Fee charged by Coorest.|


### getFeePercent

*This function fetches fee percent & divider from CCO2 token contract.*


```solidity
function getFeePercent(address carbonToken) private view returns (FeeParams memory feeParams);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`carbonToken`|`address`|CCO2 token address.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`feeParams`|`FeeParams`|Fee percentage & the fee divider.|


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

## Errors
### FeePercentageGreaterThanDivider

```solidity
error FeePercentageGreaterThanDivider();
```

### FeeRetireDividerIsZero

```solidity
error FeeRetireDividerIsZero();
```

### RetireAmountIsZero

```solidity
error RetireAmountIsZero();
```

## Structs
### FeeParams

```solidity
struct FeeParams {
    uint256 feeRetireBp;
    uint256 feeRetireDivider;
}
```

