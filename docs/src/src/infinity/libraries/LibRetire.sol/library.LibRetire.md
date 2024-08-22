# LibRetire
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/infinity/libraries/LibRetire.sol)

**Author:**
Cujo


## Functions
### retireReceivedCarbon

Retire received carbon based on the bridge of the provided pool tokens using default redemption


```solidity
function retireReceivedCarbon(
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
|`poolToken`|`address`|           Pool token used to retire|
|`amount`|`uint256`|              The amount of carbon to retire|
|`retiringAddress`|`address`||
|`retiringEntityString`|`string`|String description of the retiring entity|
|`beneficiaryAddress`|`address`|  0x address for the beneficiary|
|`beneficiaryString`|`string`|   String description of the beneficiary|
|`retirementMessage`|`string`|   String message for this specific retirement|


### retireReceivedExactCarbonSpecific

Retire received carbon based on the bridge of the provided pool tokens using specific redemption


```solidity
function retireReceivedExactCarbonSpecific(
    address poolToken,
    address projectToken,
    uint256 amount,
    address retiringAddress,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage
) internal returns (uint256 redeemedAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|           Pool token used to retire|
|`projectToken`|`address`|        Project token being retired|
|`amount`|`uint256`|              The amount of carbon to retire|
|`retiringAddress`|`address`||
|`retiringEntityString`|`string`|String description of the retiring entity|
|`beneficiaryAddress`|`address`|  0x address for the beneficiary|
|`beneficiaryString`|`string`|   String description of the beneficiary|
|`retirementMessage`|`string`|   String message for this specific retirement|


### retireReceivedCreditToken

Retire received carbon based on the bridge of the provided pool tokens using default redemption


```solidity
function retireReceivedCreditToken(
    address creditToken,
    uint256 tokenId,
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
|`creditToken`|`address`|         Pool token used to retire|
|`tokenId`|`uint256`||
|`amount`|`uint256`|              The amount of carbon to retire|
|`retiringAddress`|`address`||
|`retiringEntityString`|`string`|String description of the retiring entity|
|`beneficiaryAddress`|`address`|  0x address for the beneficiary|
|`beneficiaryString`|`string`|   String description of the beneficiary|
|`retirementMessage`|`string`|   String message for this specific retirement|


### retireReceivedCreditToken

Retire received carbon based on the bridge of the provided pool tokens using default redemption


```solidity
function retireReceivedCreditToken(address creditToken, uint256 tokenId, uint256 amount, RetireDetails memory details)
    internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`creditToken`|`address`|         Credit token used to retire|
|`tokenId`|`uint256`|             Token Id for the credit (if applicable)|
|`amount`|`uint256`|              The amount of carbon to retire|
|`details`|`RetireDetails`|             Encoded struct of retirement details needed for the retirement|


### retireReceivedCarbonSpecificFromSource

Additional function to handle the differences in wanting to fully retire x pool tokens specifically


```solidity
function retireReceivedCarbonSpecificFromSource(
    address poolToken,
    address projectToken,
    uint256 amount,
    address retiringAddress,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage
) internal returns (uint256 redeemedAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|           Pool token used to retire|
|`projectToken`|`address`|        Project token being retired|
|`amount`|`uint256`|              The amount of carbon to retire|
|`retiringAddress`|`address`||
|`retiringEntityString`|`string`|String description of the retiring entity|
|`beneficiaryAddress`|`address`|  0x address for the beneficiary|
|`beneficiaryString`|`string`|   String description of the beneficiary|
|`retirementMessage`|`string`|   String message for this specific retirement|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`redeemedAmount`|`uint256`|     Number of pool tokens redeemed|


### getTotalCarbon

Returns the total carbon needed fee included


```solidity
function getTotalCarbon(uint256 retireAmount) internal view returns (uint256 totalCarbon);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`retireAmount`|`uint256`|     Pool token used to retire|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`totalCarbon`|`uint256`|     Total pool token needed|


### getTotalCarbonSpecific

Returns the total carbon needed fee included


```solidity
function getTotalCarbonSpecific(address poolToken, uint256 retireAmount) internal view returns (uint256 totalCarbon);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|        Pool token used to retire|
|`retireAmount`|`uint256`|     Amount of carbon wanting to retire|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`totalCarbon`|`uint256`|     Total pool token needed|


### getFee

Returns the total fee needed to retire x number of tokens


```solidity
function getFee(uint256 carbonAmount) internal view returns (uint256 fee);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`carbonAmount`|`uint256`|     Amount being retired|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`fee`|`uint256`|             Total fee charged|


### saveRetirementDetails

Saves the details of the retirement over to KlimaCarbonRetirements and project details within AppStorage


```solidity
function saveRetirementDetails(
    address poolToken,
    address projectToken,
    uint256 amount,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolToken`|`address`|            Pool token used to retire|
|`projectToken`|`address`|         Pool token used to retire|
|`amount`|`uint256`|               Amount of carbon wanting to retire|
|`beneficiaryAddress`|`address`|   0x address for the beneficiary|
|`beneficiaryString`|`string`|    String description of the beneficiary|
|`retirementMessage`|`string`|    String message for this specific retirement|


### getTotalRetirements


```solidity
function getTotalRetirements(address account) internal view returns (uint256 totalRetirements);
```

### getTotalCarbonRetired


```solidity
function getTotalCarbonRetired(address account) internal view returns (uint256 totalCarbonRetired);
```

### getTotalPoolRetired


```solidity
function getTotalPoolRetired(address account, address poolToken) internal view returns (uint256 totalPoolRetired);
```

### getTotalProjectRetired


```solidity
function getTotalProjectRetired(address account, address projectToken) internal view returns (uint256);
```

### getTotalRewardsClaimed


```solidity
function getTotalRewardsClaimed(address account) internal view returns (uint256 totalClaimed);
```

### getRetirementDetails


```solidity
function getRetirementDetails(address account, uint256 retirementIndex)
    internal
    view
    returns (
        address poolTokenAddress,
        address projectTokenAddress,
        address beneficiaryAddress,
        string memory beneficiary,
        string memory retirementMessage,
        uint256 amount
    );
```

## Structs
### RetireDetails

```solidity
struct RetireDetails {
    address retiringAddress;
    string retiringEntityString;
    address beneficiaryAddress;
    string beneficiaryString;
    string retirementMessage;
    string beneficiaryLocation;
    string consumptionCountryCode;
    uint256 consumptionPeriodStart;
    uint256 consumptionPeriodEnd;
}
```

## Enums
### CarbonBridge

```solidity
enum CarbonBridge {
    TOUCAN,
    MOSS,
    C3,
    ICR,
    COOREST
}
```

