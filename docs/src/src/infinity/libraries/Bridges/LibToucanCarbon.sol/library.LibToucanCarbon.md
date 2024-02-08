# LibToucanCarbon
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/704b462e69030cb9a43680057bee91d745d579ba/src/infinity/libraries/Bridges/LibToucanCarbon.sol)

**Author:**
Cujo


## Functions
### redeemAutoAndRetire

Redeems Toucan pool tokens using default redemtion and retires the TCO2


```solidity
function redeemAutoAndRetire(
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
|`poolToken`|`address`|            Pool token to use for this retirement|
|`amount`|`uint256`|               Amount of the project token to retire|
|`retiringAddress`|`address`|      Address initiating this retirement|
|`retiringEntityString`|`string`| String description of the retiring entity|
|`beneficiaryAddress`|`address`|   0x address for the beneficiary|
|`beneficiaryString`|`string`|    String description of the beneficiary|
|`retirementMessage`|`string`|    String message for this specific retirement|


### redeemSpecificAndRetire

Redeems Toucan pool tokens using specific redemtion and retires the TCO2


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
) internal returns (uint256 retiredAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|            Pool token to use for this retirement|
|`projectToken`|`address`|         Project token to use for this retirement|
|`amount`|`uint256`|               Amount of the project token to retire|
|`retiringAddress`|`address`|      Address initiating this retirement|
|`retiringEntityString`|`string`| String description of the retiring entity|
|`beneficiaryAddress`|`address`|   0x address for the beneficiary|
|`beneficiaryString`|`string`|    String description of the beneficiary|
|`retirementMessage`|`string`|    String message for this specific retirement|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`retiredAmount`|`uint256`|       The amount of TCO2 retired|


### retireTCO2

Redeems Toucan TCO2s


```solidity
function retireTCO2(
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
|`poolToken`|`address`|            Pool token to use for this retirement|
|`projectToken`|`address`|         Project token to use for this retirement|
|`amount`|`uint256`|               Amount of the project token to retire|
|`retiringAddress`|`address`|      Address initiating this retirement|
|`retiringEntityString`|`string`| String description of the retiring entity|
|`beneficiaryAddress`|`address`|   0x address for the beneficiary|
|`beneficiaryString`|`string`|    String description of the beneficiary|
|`retirementMessage`|`string`|    String message for this specific retirement|


### sendRetireCert

Send the ERC-721 retirement certificate received to a beneficiary


```solidity
function sendRetireCert(address _beneficiary) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_beneficiary`|`address`|         Beneficiary to send the certificate to|


### getSpecificRedeemFee

Calculates the additional pool tokens needed to specifically redeem x TCO2s


```solidity
function getSpecificRedeemFee(address poolToken, uint256 amount) internal view returns (uint256 poolFeeAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|            Pool token to redeem|
|`amount`|`uint256`|               Amount of TCO2 needed|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`poolFeeAmount`|`uint256`|       Number of additional pool tokens needed|


### getSpecificRetireAmount

Returns the number of TCO2s retired when selectively redeeming x pool tokens


```solidity
function getSpecificRetireAmount(address poolToken, uint256 amount) internal view returns (uint256 retireAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|            Pool token to redeem|
|`amount`|`uint256`|               Amount of pool tokens redeemed|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`retireAmount`|`uint256`|       Number TCO2s that can be retired.|


### redeemPoolAuto

Simple wrapper to use redeem Toucan pools using the default list


```solidity
function redeemPoolAuto(address poolToken, uint256 amount, LibTransfer.To toMode)
    internal
    returns (address[] memory projectTokens, uint256[] memory amounts);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|            Pool token to redeem|
|`amount`|`uint256`|               Amount of tokens being redeemed|
|`toMode`|`LibTransfer.To`|               Where to send TCO2 tokens|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`projectTokens`|`address[]`|       TCO2 token addresses redeemed|
|`amounts`|`uint256[]`|             TCO2 token amounts redeemed|


### redeemPoolSpecific

Simple wrapper to use redeem Toucan pools using the specific list


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
|`poolToken`|`address`|            Pool token to redeem|
|`projectTokens`|`address[]`|        Project tokens to redeem|
|`amounts`|`uint256[]`|              Token amounts to redeem|
|`toMode`|`LibTransfer.To`|               Where to send TCO2 tokens|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[]`|redeemedAmounts      TCO2 token amounts redeemed|


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

