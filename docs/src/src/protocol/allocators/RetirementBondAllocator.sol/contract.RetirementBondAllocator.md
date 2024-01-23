# RetirementBondAllocator
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/allocators/RetirementBondAllocator.sol)

**Inherits:**
Ownable2Step

**Author:**
Cujo

A contract for allocating retirement bonds using excess reserves from the Klima Treasury.


## State Variables
### TREASURY
Address of the Treasury contract.


```solidity
address public constant TREASURY = 0x7Dd4f0B986F032A44F913BF92c9e8b7c17D77aD7;
```


### DAO
Address of the DAO multi-sig.


```solidity
address public constant DAO = 0x65A5076C0BA74e5f3e069995dc3DAB9D197d995c;
```


### maxReservePercent
Maximum value of reserves or Treasury balance to allocate. Set by the DAO. 500 = 5%


```solidity
uint public maxReservePercent;
```


### PERCENT_DIVISOR
Divisor used when calculating percentages.


```solidity
uint public constant PERCENT_DIVISOR = 10_000;
```


### bondContract
Retirement bond contract being used.


```solidity
address public bondContract;
```


## Functions
### constructor


```solidity
constructor(address _bondContract);
```

### onlyDAO

Modifier to ensure that the caller is the DAO multi-sig.


```solidity
modifier onlyDAO();
```

### fundBonds

Funds retirement bonds with a specified amount of tokens.


```solidity
function fundBonds(address token, uint amount) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The address of the token to fund the retirement bonds with.|
|`amount`|`uint256`|The amount of tokens to fund the retirement bonds with.|


### closeBonds

*Closes the retirement bonds market for a specified token, transferring any remaining tokens to the treasury.*


```solidity
function closeBonds(address token) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The address of the token for which to close the retirement bonds market.|


### updateBondContract

Updates the retirement bond contract being used.


```solidity
function updateBondContract(address _bondContract) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_bondContract`|`address`|The address of the new retirement bond contract.|


### updateMaxReservePercent

*Updates the maximum reserve percentage allowed.*


```solidity
function updateMaxReservePercent(uint _maxReservePercent) external onlyDAO;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_maxReservePercent`|`uint256`|The new maximum reserve percentage allowed. 500 = 5%.|


## Events
### MaxPercentUpdated

```solidity
event MaxPercentUpdated(uint oldMax, uint newMax);
```

