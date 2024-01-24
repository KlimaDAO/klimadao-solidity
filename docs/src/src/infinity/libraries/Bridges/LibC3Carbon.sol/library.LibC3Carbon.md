# LibC3Carbon
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/29fd912e7e35bfd36ad9c6e57c2a312d3aed3640/src/infinity/libraries/Bridges/LibC3Carbon.sol)

**Author:**
Cujo


## Functions
### freeRedeemAndRetire

Calls freeRedeem on a C3 pool and retires the underlying C3T


```solidity
function freeRedeemAndRetire(
    address poolToken,
    uint256 amount,
    address retiringAddress,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|           Pool token to use for this retirement|
|`amount`|`uint256`|              Amount of tokens to redeem and retire|
|`retiringAddress`|`address`|     Address initiating this retirement|
|`retiringEntityString`|`string`|String description of the retiring entity|
|`beneficiaryAddress`|`address`|  0x address for the beneficiary|
|`beneficiaryString`|`string`|   String description of the beneficiary|
|`retirementMessage`|`string`|   String message for this specific retirement|


### redeemSpecificAndRetire

Calls taxedRedeem on a C3 pool and retires the underlying C3T


```solidity
function redeemSpecificAndRetire(
    address poolToken,
    address projectToken,
    uint256 amount,
    address retiringAddress,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|           Pool token to use for this retirement|
|`projectToken`|`address`|        Project token being redeemed|
|`amount`|`uint256`|              Amount of tokens to redeem and retire|
|`retiringAddress`|`address`|     Address initiating this retirement|
|`retiringEntityString`|`string`|String description of the retiring entity|
|`beneficiaryAddress`|`address`|  0x address for the beneficiary|
|`beneficiaryString`|`string`|   String description of the beneficiary|
|`retirementMessage`|`string`|   String message for this specific retirement|


### retireC3T

Retire a C3T token


```solidity
function retireC3T(
    address poolToken,
    address projectToken,
    uint256 amount,
    address retiringAddress,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|           Pool token to use for this retirement|
|`projectToken`|`address`|        Project token being redeemed|
|`amount`|`uint256`|              Amount of tokens to redeem and retire|
|`retiringAddress`|`address`|     Address initiating this retirement|
|`retiringEntityString`|`string`|String description of the retiring entity|
|`beneficiaryAddress`|`address`|  0x address for the beneficiary|
|`beneficiaryString`|`string`|   String description of the beneficiary|
|`retirementMessage`|`string`|   String message for this specific retirement|


### getExactCarbonSpecificRedeemFee

Return the additional fee needed to redeem specific number of project tokens.


```solidity
function getExactCarbonSpecificRedeemFee(address poolToken, uint256 amount)
    internal
    view
    returns (uint256 poolFeeAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|           Pool token to use for this retirement|
|`amount`|`uint256`|              Amount of tokens to redeem and retire|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`poolFeeAmount`|`uint256`|      Additional C3 pool tokens needed for the redemption|


### getExactSourceSpecificRetireAmount

Return the amount that can be specifically redeemed from a C3 given x number of tokens.


```solidity
function getExactSourceSpecificRetireAmount(address poolToken, uint256 amount)
    internal
    view
    returns (uint256 retireAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|           Pool token to use for this retirement|
|`amount`|`uint256`|              Amount of tokens to redeem and retire|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`retireAmount`|`uint256`|       Amount of C3T that can be specifically redeemed from a given pool amount|


### redeemPoolAuto

Receives and redeems a number of pool tokens and sends the C3T to a destination..


```solidity
function redeemPoolAuto(address poolToken, uint256 amount, LibTransfer.To toMode)
    internal
    returns (address[] memory allProjectTokens, uint256[] memory amounts);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|           Pool token to use for this retirement|
|`amount`|`uint256`|              Amount of tokens to redeem and retire|
|`toMode`|`LibTransfer.To`|              Where to send redeemed tokens to|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`allProjectTokens`|`address[]`|   Default redeem C3T list from the pool|
|`amounts`|`uint256[]`|            Amount of C3T that was redeemed from the pool|


### redeemPoolSpecific

Receives and redeems a number of pool tokens and sends the C3T to a destination.


```solidity
function redeemPoolSpecific(
    address poolToken,
    address[] memory projectTokens,
    uint256[] memory amounts,
    LibTransfer.To toMode
) internal returns (uint256[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|            Pool token to use for this retirement|
|`projectTokens`|`address[]`|        Project tokens to redeem|
|`amounts`|`uint256[]`|              Amounts of the project tokens to redeem|
|`toMode`|`LibTransfer.To`|               Where to send redeemed tokens to|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[]`|redeemedAmounts      Amounts of the project tokens redeemed|


### isValid


```solidity
function isValid(address token) internal returns (bool);
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
    uint256 retiredAmount
);
```

