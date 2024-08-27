# RetireMossCarbon
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/retirement_v1/RetireMossCarbon.sol)

**Inherits:**
Initializable, ContextUpgradeable, OwnableUpgradeable


## State Variables
### feeAmount
=== State Variables and Mappings ===

feeAmount represents the fee to be bonded for KLIMA. 0.1% increments. 10 = 1%


```solidity
uint256 public feeAmount;
```


### carbonChain

```solidity
address public carbonChain;
```


### masterAggregator

```solidity
address public masterAggregator;
```


### isPoolToken

```solidity
mapping(address => bool) public isPoolToken;
```


### poolRouter

```solidity
mapping(address => address) public poolRouter;
```


## Functions
### initialize


```solidity
function initialize() public initializer;
```

### retireMoss

This function transfers source tokens if needed, swaps to the Moss
pool token, and then retires via their CarbonChain interface. Needed source
token amount is expected to be held by the caller to use.


```solidity
function retireMoss(
    address _sourceToken,
    address _poolToken,
    uint256 _amount,
    bool _amountInCarbon,
    address _beneficiaryAddress,
    string memory _beneficiaryString,
    string memory _retirementMessage,
    address _retiree
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
|`_retiree`|`address`|The original sender of the transaction.|


### _retireCarbon

Retires the MCO2 tokens on Polygon where they will be bridged back to L1.
Emits a retirement event and updates the KlimaCarbonRetirements contract with
retirement details and amounts.


```solidity
function _retireCarbon(
    uint256 _totalAmount,
    address _beneficiaryAddress,
    string memory _beneficiaryString,
    string memory _retirementMessage,
    address _poolToken
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_totalAmount`|`uint256`|Total pool tokens being retired. Expected uint with 18 decimals.|
|`_beneficiaryAddress`|`address`|Address of the beneficiary if different than sender. Value is set to _msgSender() if null is sent.|
|`_beneficiaryString`|`string`|String that can be used to describe the beneficiary|
|`_retirementMessage`|`string`|String for specific retirement message if needed.|
|`_poolToken`|`address`|Address of pool token being used to retire.|


### _transferSourceTokens

Transfers the needed source tokens from the caller to perform any needed
swaps and then retire the tokens.


```solidity
function _transferSourceTokens(address _sourceToken, address _poolToken, uint256 _amount, bool _amountInCarbon)
    internal
    returns (uint256, uint256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_sourceToken`|`address`|The contract address of the token being supplied.|
|`_poolToken`|`address`|The contract address of the pool token being retired.|
|`_amount`|`uint256`|The amount being supplied. Expressed in either the total carbon to offset or the total source to spend. See _amountInCarbon.|
|`_amountInCarbon`|`bool`|Bool indicating if _amount is in carbon or source.|


### _stakedToUnstaked

Unwraps/unstakes any KLIMA needed to regular KLIMA.


```solidity
function _stakedToUnstaked(address _klimaType, uint256 _amountIn) internal returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_klimaType`|`address`|Address of the KLIMA type being used.|
|`_amountIn`|`uint256`|Amount of total KLIMA needed.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Returns the total number of KLIMA after unwrapping/unstaking.|


### getNeededBuyAmount

Call the UniswapV2 routers for needed amounts on token being retired.
Also calculates and returns any fee needed in the pool token total.


```solidity
function getNeededBuyAmount(address _sourceToken, address _poolToken, uint256 _poolAmount, bool _specificRetire)
    public
    view
    returns (uint256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_sourceToken`|`address`|Address of token being used to purchase the pool token.|
|`_poolToken`|`address`|Address of pool token being used.|
|`_poolAmount`|`uint256`|Amount of tokens being retired.|
|`_specificRetire`|`bool`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Tuple of the total pool amount needed, followed by the fee.|
|`<none>`|`uint256`||


### getSwapPath

Creates an array of addresses to use in performing any needed
swaps to receive the pool token from the source token.

*This function will produce an invalid path if the source token
does not have a direct USDC LP route on the pool's AMM. The resulting
transaction would revert.*


```solidity
function getSwapPath(address _sourceToken, address _poolToken) public view returns (address[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_sourceToken`|`address`|Address of token being used to purchase the pool token.|
|`_poolToken`|`address`|Address of pool token being used.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|Array of addresses to be used as the path for the swap.|


### _swapForExactCarbon

Swaps the source token for an exact number of carbon tokens, and
returns any dust to the initiator.

*This is only called if the _amountInCarbon bool is set to true.*


```solidity
function _swapForExactCarbon(
    address _sourceToken,
    address _poolToken,
    uint256 _carbonAmount,
    uint256 _amountIn,
    address _retiree
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_sourceToken`|`address`|Address of token being used to purchase the pool token.|
|`_poolToken`|`address`|Address of pool token being used.|
|`_carbonAmount`|`uint256`|Total carbon needed.|
|`_amountIn`|`uint256`|Maximum amount of source tokens.|
|`_retiree`|`address`|Initiator of the retirement to return any dust.|


### _swapExactForCarbon

Swaps an exact number of source tokens for carbon tokens.

*This is only called if the _amountInCarbon bool is set to false.*


```solidity
function _swapExactForCarbon(address _sourceToken, address _poolToken, uint256 _amountIn)
    internal
    returns (uint256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_sourceToken`|`address`|Address of token being used to purchase the pool token.|
|`_poolToken`|`address`|Address of pool token being used.|
|`_amountIn`|`uint256`|Total source tokens to swap.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Returns the resulting carbon amount to retire and the fee from the results of the swap.|
|`<none>`|`uint256`||


### _returnTradeDust

Returns any trade dust to the designated address. If sKLIMA or
wsKLIMA was provided as a source token, it is re-staked and/or wrapped
before transferring back.


```solidity
function _returnTradeDust(uint256[] memory _amounts, address _sourceToken, uint256 _amountIn, address _retiree)
    internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amounts`|`uint256[]`|The amounts resulting from the Uniswap tradeTokensForExactTokens.|
|`_sourceToken`|`address`|Address of token being used to purchase the pool token.|
|`_amountIn`|`uint256`|Total source tokens initially provided.|
|`_retiree`|`address`|Address where to send the dust.|


### setFeeAmount

Set the fee for the helper


```solidity
function setFeeAmount(uint256 _amount) external onlyOwner returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|New fee amount, in .1% increments. 10 = 1%|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool|


### setPoolRouter

Update the router for an existing pool


```solidity
function setPoolRouter(address _poolToken, address _router) external onlyOwner returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_poolToken`|`address`|Pool being updated|
|`_router`|`address`|New router address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool|


### addPool

Add a new carbon pool to retire with helper contract


```solidity
function addPool(address _poolToken, address _router) external onlyOwner returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_poolToken`|`address`|Pool being added|
|`_router`|`address`|UniswapV2 router to route trades through for non-pool retirements|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool|


### removePool

Remove a carbon pool to retire with helper contract


```solidity
function removePool(address _poolToken) external onlyOwner returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_poolToken`|`address`|Pool being removed|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool|


### feeWithdraw

Allow withdrawal of any tokens sent in error


```solidity
function feeWithdraw(address _token, address _recipient) public onlyOwner returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|Address of token to transfer|
|`_recipient`|`address`|Address where to send tokens.|


### setCarbonChain

Allow the contract owner to update the Moss CarbonChain Proxy address used.


```solidity
function setCarbonChain(address _newAddress) external onlyOwner returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newAddress`|`address`|New address for contract needing to be updated.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool|


### setMasterAggregator

Allow the contract owner to update the master aggregator proxy address used.


```solidity
function setMasterAggregator(address _newAddress) external onlyOwner returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newAddress`|`address`|New address for contract needing to be updated.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool|


## Events
### MossRetired
=== Event Setup ===


```solidity
event MossRetired(
    address indexed retiringAddress,
    address indexed beneficiaryAddress,
    string beneficiaryString,
    string retirementMessage,
    address indexed carbonPool,
    uint256 retiredAmount
);
```

### PoolAdded

```solidity
event PoolAdded(address indexed carbonPool, address indexed poolRouter);
```

### PoolRemoved

```solidity
event PoolRemoved(address indexed carbonPool);
```

### PoolRouterChanged

```solidity
event PoolRouterChanged(address indexed carbonPool, address indexed oldRouter, address indexed newRouter);
```

### FeeUpdated

```solidity
event FeeUpdated(uint256 oldFee, uint256 newFee);
```

### CarbonChainUpdated

```solidity
event CarbonChainUpdated(address indexed oldAddress, address indexed newAddress);
```

### MasterAggregatorUpdated

```solidity
event MasterAggregatorUpdated(address indexed oldAddress, address indexed newAddress);
```

