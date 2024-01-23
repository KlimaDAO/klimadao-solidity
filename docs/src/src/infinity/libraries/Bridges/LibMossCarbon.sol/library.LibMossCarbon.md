# LibMossCarbon
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/libraries/Bridges/LibMossCarbon.sol)

**Author:**
Cujo


## Functions
### offsetCarbon

Retires Moss MCO2 tokens on Polygon


```solidity
function offsetCarbon(
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
|`poolToken`|`address`|            Pool token to use for this retirement|
|`amount`|`uint256`|               Amounts of the project tokens to retire|
|`retiringAddress`|`address`|     Address initiating this retirement|
|`retiringEntityString`|`string`|String description of the retiring entity|
|`beneficiaryAddress`|`address`|  0x address for the beneficiary|
|`beneficiaryString`|`string`|   String description of the beneficiary|
|`retirementMessage`|`string`|   String message for this specific retirement|


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

