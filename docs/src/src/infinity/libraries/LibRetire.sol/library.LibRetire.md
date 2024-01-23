# LibRetire
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/libraries/LibRetire.sol)

**Author:**
Cujo


## Functions
### retireReceivedCarbon

Retire received carbon based on the bridge of the provided pool tokens using default redemption


```solidity
function retireReceivedCarbon(
    address poolToken,
    uint amount,
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
    uint amount,
    address retiringAddress,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage
) internal returns (uint redeemedAmount);
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


### retireReceivedCarbonSpecificFromSource

Additional function to handle the differences in wanting to fully retire x pool tokens specifically


```solidity
function retireReceivedCarbonSpecificFromSource(
    address poolToken,
    address projectToken,
    uint amount,
    address retiringAddress,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage
) internal returns (uint redeemedAmount);
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
function getTotalCarbon(uint retireAmount) internal view returns (uint totalCarbon);
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
function getTotalCarbonSpecific(address poolToken, uint retireAmount) internal view returns (uint totalCarbon);
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
function getFee(uint carbonAmount) internal view returns (uint fee);
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
    uint amount,
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
function getTotalRetirements(address account) internal view returns (uint totalRetirements);
```

### getTotalCarbonRetired


```solidity
function getTotalCarbonRetired(address account) internal view returns (uint totalCarbonRetired);
```

### getTotalPoolRetired


```solidity
function getTotalPoolRetired(address account, address poolToken) internal view returns (uint totalPoolRetired);
```

### getTotalProjectRetired


```solidity
function getTotalProjectRetired(address account, address projectToken) internal view returns (uint);
```

### getTotalRewardsClaimed


```solidity
function getTotalRewardsClaimed(address account) internal view returns (uint totalClaimed);
```

### getRetirementDetails


```solidity
function getRetirementDetails(address account, uint retirementIndex)
    internal
    view
    returns (
        address poolTokenAddress,
        address projectTokenAddress,
        address beneficiaryAddress,
        string memory beneficiary,
        string memory retirementMessage,
        uint amount
    );
```

## Enums
### CarbonBridge

```solidity
enum CarbonBridge {
    TOUCAN,
    MOSS,
    C3
}
```

