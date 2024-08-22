# KlimaCarbonRetirements
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/retirement_v1/KlimaCarbonRetirements.sol)

**Inherits:**
[Ownable](/src/protocol/staking/utils/KlimaTreasury.sol/contract.Ownable.md)

This is used to store any offset retirements made through Klima retirement helper contracts.


## State Variables
### retirements

```solidity
mapping(address => Retirement) public retirements;
```


### isHelperContract

```solidity
mapping(address => bool) public isHelperContract;
```


### isMinterContract

```solidity
mapping(address => bool) public isMinterContract;
```


## Functions
### carbonRetired

Stores the details of an offset transaction for future use


```solidity
function carbonRetired(
    address _retiree,
    address _pool,
    uint256 _amount,
    string calldata _beneficiaryString,
    string calldata _retirementMessage
) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_retiree`|`address`|Address of the retiree. Not the address of a helper contract.|
|`_pool`|`address`|Address of the carbon pool token.|
|`_amount`|`uint256`|Number of tons offset. Expected is with 18 decimals.|
|`_beneficiaryString`|`string`|String that can be used to describe the beneficiary|
|`_retirementMessage`|`string`|String for specific retirement message if needed.|


### getUnclaimedTotal

Return any unclaimed NFT totals for an address


```solidity
function getUnclaimedTotal(address _minter) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_minter`|`address`|Address of user trying to mint.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The net amount of offsets not used for minting an NFT to date.|


### offsetClaimed

This function updates the total claimed amount for minting an NFT.


```solidity
function offsetClaimed(address _minter, uint256 _amount) public returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_minter`|`address`|Address of the user trying to mint.|
|`_amount`|`uint256`|Amount being claimed for the mint. Expected value in 18 decimals.|


### getRetirementIndexInfo

This returns information on a specific retirement for an address.


```solidity
function getRetirementIndexInfo(address _retiree, uint256 _index)
    public
    view
    returns (address, uint256, string memory, string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_retiree`|`address`|Address that retired the offsets.|
|`_index`|`uint256`|Index of all retirements made. Starts at 0.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|Returns a tuple of the address for the pool address, amount offset in 18 decimals, and beneficiary description and message used in the retirement.|
|`<none>`|`uint256`||
|`<none>`|`string`||
|`<none>`|`string`||


### getRetirementPoolInfo

This returns the total amount offset by an address for a specific pool.


```solidity
function getRetirementPoolInfo(address _retiree, address _pool) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_retiree`|`address`|Address that performed the retirement.|
|`_pool`|`address`|Address of the pool token.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Int with 18 decimals for the total amount offset for this pool token.|


### getRetirementTotals

This returns totals about retirements and claims on an address


```solidity
function getRetirementTotals(address _retiree) public view returns (uint256, uint256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_retiree`|`address`|Address that performed the retirement.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Int tuple. Total retirements, total tons retired, total tons claimed for NFTs.|
|`<none>`|`uint256`||
|`<none>`|`uint256`||


### addHelperContract

Allow contract owner to whitelist new helper contracts. This is to prevent writing abuse from external interfaces.


```solidity
function addHelperContract(address _helper) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_helper`|`address`|Address of the helper contract.|


### removeHelperContract

Allow contract owner to remove helper contracts. This is to prevent writing abuse from external interfaces.


```solidity
function removeHelperContract(address _helper) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_helper`|`address`|Address of the helper contract.|


### addMinterContract

Allow contract owner to whitelist new reward contracts. This is to prevent writing abuse from external interfaces.


```solidity
function addMinterContract(address _minter) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_minter`|`address`|Address of the helper contract.|


### removeMinterContract

Allow contract owner to remove reward contracts. This is to prevent writing abuse from external interfaces.


```solidity
function removeMinterContract(address _minter) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_minter`|`address`|Address of the helper contract.|


## Events
### HelperAdded

```solidity
event HelperAdded(address helper);
```

### HelperRemoved

```solidity
event HelperRemoved(address helper);
```

### MinterAdded

```solidity
event MinterAdded(address minter);
```

### MinterRemoved

```solidity
event MinterRemoved(address minter);
```

## Structs
### Retirement

```solidity
struct Retirement {
    uint256 totalRetirements;
    uint256 totalCarbonRetired;
    uint256 totalClaimed;
    mapping(uint256 => address) retiredPool;
    mapping(uint256 => uint256) retiredAmount;
    mapping(uint256 => string) retirementBeneficiary;
    mapping(uint256 => string) retirementMessage;
    mapping(address => uint256) totalPoolRetired;
}
```

