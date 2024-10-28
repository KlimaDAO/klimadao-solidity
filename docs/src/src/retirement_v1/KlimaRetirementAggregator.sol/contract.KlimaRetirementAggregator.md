# KlimaRetirementAggregator
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/retirement_v1/KlimaRetirementAggregator.sol)

**Inherits:**
Initializable, ContextUpgradeable, OwnableUpgradeable

**Author:**
KlimaDAO

This is the master aggregator contract for the Klima retirement utility.
This allows a user to provide a source token and an approved carbon pool token to retire.
If the source is different than the pool, it will attempt to swap to that pool then retire.


## State Variables
### KLIMA
=== State Variables and Mappings ===


```solidity
address public KLIMA;
```


### sKLIMA

```solidity
address public sKLIMA;
```


### wsKLIMA

```solidity
address public wsKLIMA;
```


### USDC

```solidity
address public USDC;
```


### staking

```solidity
address public staking;
```


### stakingHelper

```solidity
address public stakingHelper;
```


### treasury

```solidity
address public treasury;
```


### klimaRetirementStorage

```solidity
address public klimaRetirementStorage;
```


### isPoolToken

```solidity
mapping(address => bool) public isPoolToken;
```


### poolBridge

```solidity
mapping(address => uint256) public poolBridge;
```


### bridgeHelper

```solidity
mapping(uint256 => address) public bridgeHelper;
```


### INFINITY

```solidity
address public constant INFINITY = 0x8cE54d9625371fb2a068986d32C85De8E6e995f8;
```


## Functions
### initialize


```solidity
function initialize() public initializer;
```

### retireCarbon

=== Non Specific Auto Retirements

This function will retire a carbon pool token that is held
in the caller's wallet. Depending on the pool provided the appropriate
retirement helper will be used as defined in the bridgeHelper mapping.
If a token other than the pool is provided then the helper will attempt
to swap to the appropriate pool and then retire.


```solidity
function retireCarbon(
    address _sourceToken,
    address _poolToken,
    uint256 _amount,
    bool _amountInCarbon,
    address _beneficiaryAddress,
    string memory _beneficiaryString,
    string memory _retirementMessage
) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_sourceToken`|`address`|The contract address of the token being supplied.|
|`_poolToken`|`address`|The contract address of the pool token being retired.|
|`_amount`|`uint256`|The amount being supplied. Expressed in either the total carbon to offset or the total source to spend. See _amountInCarbon.|
|`_amountInCarbon`|`bool`|Bool indicating if _amount is in carbon or source.|
|`_beneficiaryAddress`|`address`|Address of the beneficiary of the retirement.|
|`_beneficiaryString`|`string`|String representing the beneficiary. A name perhaps.|
|`_retirementMessage`|`string`|Specific message relating to this retirement event.|


### retireCarbon


```solidity
function retireCarbon(
    address _sourceToken,
    address _poolToken,
    uint256 _amount,
    bool _amountInCarbon,
    string memory _retireEntityString,
    address _beneficiaryAddress,
    string memory _beneficiaryString,
    string memory _retirementMessage
) public;
```

### retireCarbonFrom

This function will retire a carbon pool token that has been
transferred to this contract. Useful when an intermediary contract has
approval to transfer the source tokens from the initiator.
Depending on the pool provided the appropriate retirement helper will
be used as defined in the bridgeHelper mapping. If a token other than
the pool is provided then the helper will attempt to swap to the
appropriate pool and then retire.


```solidity
function retireCarbonFrom(
    address _initiator,
    address _sourceToken,
    address _poolToken,
    uint256 _amount,
    bool _amountInCarbon,
    address _beneficiaryAddress,
    string memory _beneficiaryString,
    string memory _retirementMessage
) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_initiator`|`address`|The original sender of the transaction.|
|`_sourceToken`|`address`|The contract address of the token being supplied.|
|`_poolToken`|`address`|The contract address of the pool token being retired.|
|`_amount`|`uint256`|The amount being supplied. Expressed in either the total carbon to offset or the total source to spend. See _amountInCarbon.|
|`_amountInCarbon`|`bool`|Bool indicating if _amount is in carbon or source.|
|`_beneficiaryAddress`|`address`|Address of the beneficiary of the retirement.|
|`_beneficiaryString`|`string`|String representing the beneficiary. A name perhaps.|
|`_retirementMessage`|`string`|Specific message relating to this retirement event.|


### _retireCarbon

Internal function that checks to make sure the needed source tokens
have been transferred to this contract, then calls the retirement function
on the bridge's specific helper contract.


```solidity
function _retireCarbon(
    address _sourceToken,
    address _poolToken,
    uint256 _amount,
    bool _amountInCarbon,
    address _beneficiaryAddress,
    string memory _beneficiaryString,
    string memory _retirementMessage,
    address _retiree
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_sourceToken`|`address`|The contract address of the token being supplied.|
|`_poolToken`|`address`|The contract address of the pool token being retired.|
|`_amount`|`uint256`|The amount being supplied. Expressed in either the total carbon to offset or the total source to spend. See _amountInCarbon.|
|`_amountInCarbon`|`bool`|Bool indicating if _amount is in carbon or source.|
|`_beneficiaryAddress`|`address`|Address of the beneficiary of the retirement.|
|`_beneficiaryString`|`string`|String representing the beneficiary. A name perhaps.|
|`_retirementMessage`|`string`|Specific message relating to this retirement event.|
|`_retiree`|`address`|Address of the initiator where source tokens originated.|


### _retireCarbon


```solidity
function _retireCarbon(
    address _sourceToken,
    address _poolToken,
    uint256 _amount,
    bool _amountInCarbon,
    string memory _retireEntityString,
    address _beneficiaryAddress,
    string memory _beneficiaryString,
    string memory _retirementMessage,
    address _retiree
) internal;
```

### retireCarbonSpecific

=== Specific offset selection retirements ===

This function will retire a carbon pool token that is held
in the caller's wallet. Depending on the pool provided the appropriate
retirement helper will be used as defined in the bridgeHelper mapping.
If a token other than the pool is provided then the helper will attempt
to swap to the appropriate pool and then retire.


```solidity
function retireCarbonSpecific(
    address _sourceToken,
    address _poolToken,
    uint256 _amount,
    bool _amountInCarbon,
    address _beneficiaryAddress,
    string memory _beneficiaryString,
    string memory _retirementMessage,
    address[] memory _carbonList
) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_sourceToken`|`address`|The contract address of the token being supplied.|
|`_poolToken`|`address`|The contract address of the pool token being retired.|
|`_amount`|`uint256`|The amount being supplied. Expressed in either the total carbon to offset or the total source to spend. See _amountInCarbon.|
|`_amountInCarbon`|`bool`|Bool indicating if _amount is in carbon or source.|
|`_beneficiaryAddress`|`address`|Address of the beneficiary of the retirement.|
|`_beneficiaryString`|`string`|String representing the beneficiary. A name perhaps.|
|`_retirementMessage`|`string`|Specific message relating to this retirement event.|
|`_carbonList`|`address[]`||


### retireCarbonSpecific


```solidity
function retireCarbonSpecific(
    address _sourceToken,
    address _poolToken,
    uint256 _amount,
    bool _amountInCarbon,
    string memory _retireEntityString,
    address _beneficiaryAddress,
    string memory _beneficiaryString,
    string memory _retirementMessage,
    address[] memory _carbonList
) public;
```

### retireCarbonSpecificFrom


```solidity
function retireCarbonSpecificFrom(
    address _initiator,
    address _sourceToken,
    address _poolToken,
    uint256 _amount,
    bool _amountInCarbon,
    address _beneficiaryAddress,
    string memory _beneficiaryString,
    string memory _retirementMessage,
    address[] memory _carbonList
) public;
```

### _retireCarbonSpecific

Internal function that checks to make sure the needed source tokens
have been transferred to this contract, then calls the retirement function
on the bridge's specific helper contract.


```solidity
function _retireCarbonSpecific(
    address _sourceToken,
    address _poolToken,
    uint256 _amount,
    bool _amountInCarbon,
    address _beneficiaryAddress,
    string memory _beneficiaryString,
    string memory _retirementMessage,
    address _retiree,
    address[] memory _carbonList
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_sourceToken`|`address`|The contract address of the token being supplied.|
|`_poolToken`|`address`|The contract address of the pool token being retired.|
|`_amount`|`uint256`|The amount being supplied. Expressed in either the total carbon to offset or the total source to spend. See _amountInCarbon.|
|`_amountInCarbon`|`bool`|Bool indicating if _amount is in carbon or source.|
|`_beneficiaryAddress`|`address`|Address of the beneficiary of the retirement.|
|`_beneficiaryString`|`string`|String representing the beneficiary. A name perhaps.|
|`_retirementMessage`|`string`|Specific message relating to this retirement event.|
|`_retiree`|`address`|Address of the initiator where source tokens originated.|
|`_carbonList`|`address[]`||


### _retireCarbonSpecific


```solidity
function _retireCarbonSpecific(
    address _sourceToken,
    address _poolToken,
    uint256 _amount,
    bool _amountInCarbon,
    string memory _retireEntityString,
    address _beneficiaryAddress,
    string memory _beneficiaryString,
    string memory _retirementMessage,
    address _retiree,
    address[] memory _carbonList
) internal;
```

### _prepareRetireSpecific


```solidity
function _prepareRetireSpecific(address _sourceToken, address _poolToken, uint256 _amount, bool _amountInCarbon)
    internal;
```

### getSourceAmount

=== External views and helpful functions ===

This function calls the appropriate helper for a pool token and
returns the total amount in source tokens needed to perform the transaction.
Any swap slippage buffers and fees are included in the return value.


```solidity
function getSourceAmount(address _sourceToken, address _poolToken, uint256 _amount, bool _amountInCarbon)
    public
    view
    returns (uint256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_sourceToken`|`address`|The contract address of the token being supplied.|
|`_poolToken`|`address`|The contract address of the pool token being retired.|
|`_amount`|`uint256`|The amount being supplied. Expressed in either the total carbon to offset or the total source to spend. See _amountInCarbon.|
|`_amountInCarbon`|`bool`|Bool indicating if _amount is in carbon or source.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Returns both the source amount and carbon amount as a result of swaps.|
|`<none>`|`uint256`||


### getSourceAmountSpecific

Same as getSourceAmount, but factors in the redemption fee
for specific retirements.


```solidity
function getSourceAmountSpecific(address _sourceToken, address _poolToken, uint256 _amount, bool _amountInCarbon)
    public
    view
    returns (uint256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_sourceToken`|`address`|The contract address of the token being supplied.|
|`_poolToken`|`address`|The contract address of the pool token being retired.|
|`_amount`|`uint256`|The amount being supplied. Expressed in either the total carbon to offset or the total source to spend. See _amountInCarbon.|
|`_amountInCarbon`|`bool`|Bool indicating if _amount is in carbon or source.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Returns both the source amount and carbon amount as a result of swaps.|
|`<none>`|`uint256`||


### setAddress

Allow the contract owner to update Klima protocol addresses
resulting from possible migrations.


```solidity
function setAddress(uint256 _selection, address _newAddress) external onlyOwner returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_selection`|`uint256`|Int to indicate which address is being updated.|
|`_newAddress`|`address`|New address for contract needing to be updated.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool|


### addPool

Add a new carbon pool to retire with helper contract.


```solidity
function addPool(address _poolToken, uint256 _poolBridge) external onlyOwner returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_poolToken`|`address`|Pool being added.|
|`_poolBridge`|`uint256`|Int ID of the bridge used for this token.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool|


### removePool

Remove a carbon pool to retire.


```solidity
function removePool(address _poolToken) external onlyOwner returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_poolToken`|`address`|Pool being removed.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool|


### setBridgeHelper

Set the helper contract to be used with a carbon bridge.


```solidity
function setBridgeHelper(uint256 _bridgeID, address _helper) external onlyOwner returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_bridgeID`|`uint256`|Int ID of the bridge.|
|`_helper`|`address`|Helper contract to use with this bridge.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool|


### feeWithdraw

Allow withdrawal of any tokens sent in error


```solidity
function feeWithdraw(address _token, address _recipient) external onlyOwner returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of token to transfer|
|`_recipient`|`address`||


## Events
### AddressUpdated
=== Event Setup ===


```solidity
event AddressUpdated(uint256 addressIndex, address indexed oldAddress, address indexed newAddress);
```

### PoolAdded

```solidity
event PoolAdded(address poolToken, uint256 bridge);
```

### PoolRemoved

```solidity
event PoolRemoved(address poolToken);
```

### BridgeHelperUpdated

```solidity
event BridgeHelperUpdated(uint256 bridgeID, address helper);
```

