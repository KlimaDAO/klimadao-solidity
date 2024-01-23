# RetireC3Carbon
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/retirement_v1/RetireC3Carbon.sol)

**Inherits:**
Initializable, ContextUpgradeable, OwnableUpgradeable


## State Variables
### feeAmount
=== State Variables and Mappings ===

feeAmount represents the fee to be bonded for KLIMA. 0.1% increments. 10 = 1%


```solidity
uint public feeAmount;
```


### masterAggregator

```solidity
address public masterAggregator;
```


### tridentRouter

```solidity
address public tridentRouter;
```


### bento

```solidity
address public bento;
```


### isPoolToken

```solidity
mapping(address => bool) public isPoolToken;
```


### poolRouter

```solidity
mapping(address => address) public poolRouter;
```


### tridentPool

```solidity
mapping(address => address) public tridentPool;
```


## Functions
### initialize


```solidity
function initialize() public initializer;
```

### retireC3

=== Free Redeem and Offset Functions ===

This function transfers source tokens if needed, swaps to the C3
pool token, utilizes freeRedeem, then retires the redeemed C3T. Needed source
token amount is expected to be held by the caller to use.


```solidity
function retireC3(
    address _sourceToken,
    address _poolToken,
    uint _amount,
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

Redeems the pool and retires the C3T tokens on Polygon.
Emits a retirement event and updates the KlimaCarbonRetirements contract with
retirement details and amounts.


```solidity
function _retireCarbon(
    uint _totalAmount,
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


### retireC3Specific

=== Taxed Redeem and Offset Functions ===

This function transfers source tokens if needed, swaps to the C3
pool token, utilizes taxedRedeem, then retires the redeemed C3T. Needed source
token amount is expected to be held by the caller to use.


```solidity
function retireC3Specific(
    address _sourceToken,
    address _poolToken,
    uint _amount,
    bool _amountInCarbon,
    address _beneficiaryAddress,
    string memory _beneficiaryString,
    string memory _retirementMessage,
    address _retiree,
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
|`_retiree`|`address`|The original sender of the transaction.|
|`_carbonList`|`address[]`|List of C3Ts to redeem|


### _prepareRetireSpecific

This function is mainly used to avoid stack too deep. It performs the
initial transfer and swap to the pool token for a specific retirement.


```solidity
function _prepareRetireSpecific(
    address _sourceToken,
    address _poolToken,
    uint _amount,
    bool _amountInCarbon,
    address _retiree
) internal returns (uint, uint);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_sourceToken`|`address`|The contract address of the token being supplied.|
|`_poolToken`|`address`|The contract address of the pool token being retired.|
|`_amount`|`uint256`|The amount being supplied. Expressed in either the total carbon to offset or the total source to spend. See _amountInCarbon.|
|`_amountInCarbon`|`bool`|Bool indicating if _amount is in carbon or source.|
|`_retiree`|`address`|The original sender of the transaction. To return trade dust.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|(uint256, uint256) tuple for the amount to pass to redeem and retire, and the aggregator fee.|
|`<none>`|`uint256`||


### _retireCarbonSpecific

Redeems the pool and retires the C3T tokens on Polygon.
Emits a retirement event and updates the KlimaCarbonRetirements contract with
retirement details and amounts.


```solidity
function _retireCarbonSpecific(
    uint _totalAmount,
    address _beneficiaryAddress,
    string memory _beneficiaryString,
    string memory _retirementMessage,
    address _poolToken,
    address[] memory _carbonList
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
|`_carbonList`|`address[]`|List of C3T tokens to redeem|


### _transferSourceTokens

=== Internal helper functions ===

Transfers the needed source tokens from the caller to perform any needed
swaps and then retire the tokens.


```solidity
function _transferSourceTokens(
    address _sourceToken,
    address _poolToken,
    uint _amount,
    bool _amountInCarbon,
    bool _specificRetire
) internal returns (uint, uint, uint);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_sourceToken`|`address`|The contract address of the token being supplied.|
|`_poolToken`|`address`|The contract address of the pool token being retired.|
|`_amount`|`uint256`|The amount being supplied. Expressed in either the total carbon to offset or the total source to spend. See _amountInCarbon.|
|`_amountInCarbon`|`bool`|Bool indicating if _amount is in carbon or source.|
|`_specificRetire`|`bool`||


### _stakedToUnstaked

Unwraps/unstakes any KLIMA needed to regular KLIMA.


```solidity
function _stakedToUnstaked(address _klimaType, uint _amountIn) internal returns (uint);
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


### _swapForExactCarbon

Swaps the source token for an exact number of carbon tokens, and
returns any dust to the initiator.

*This is only called if the _amountInCarbon bool is set to true.*


```solidity
function _swapForExactCarbon(
    address _sourceToken,
    address _poolToken,
    uint _carbonAmount,
    uint _amountIn,
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
function _swapExactForCarbon(address _sourceToken, address _poolToken, uint _amountIn) internal returns (uint, uint);
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
function _returnTradeDust(uint[] memory _amounts, address _sourceToken, uint _amountIn, address _retiree) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amounts`|`uint256[]`|The amounts resulting from the Uniswap tradeTokensForExactTokens.|
|`_sourceToken`|`address`|Address of token being used to purchase the pool token.|
|`_amountIn`|`uint256`|Total source tokens initially provided.|
|`_retiree`|`address`|Address where to send the dust.|


### _getSpecificCarbonFee

Gets the fee amount for a carbon pool and returns the value.


```solidity
function _getSpecificCarbonFee(address _poolToken, uint _poolAmount, bool _amountInCarbon)
    internal
    view
    returns (uint);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_poolToken`|`address`|Address of pool token being used.|
|`_poolAmount`|`uint256`|Amount of tokens being retired.|
|`_amountInCarbon`|`bool`|Bool indicating if _amount is in carbon or source.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|poolFeeAmount Fee amount for specificly redeeming a ton.|


### getNeededBuyAmount

=== External views and helpful functions ===

Call the UniswapV2 routers for needed amounts on token being retired.
Also calculates and returns any fee needed in the pool token total.


```solidity
function getNeededBuyAmount(address _sourceToken, address _poolToken, uint _poolAmount, bool _specificRetire)
    public
    view
    returns (uint, uint);
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

This creates the path for UniswapV2 to get to KLIMA. A secondary
swap will be performed in Trident to get the pool token.

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


### setFeeAmount

=== Admin Functions ===

Set the fee for the helper


```solidity
function setFeeAmount(uint _amount) external onlyOwner returns (bool);
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
function addPool(address _poolToken, address _router, address _tridentPool) external onlyOwner returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_poolToken`|`address`|Pool being added|
|`_router`|`address`|UniswapV2 router to route trades through for non-pool retirements|
|`_tridentPool`|`address`||

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


### setTrident

Allow the contract owner to update the SushiSwap Trident AMM addresses.


```solidity
function setTrident(address _tridentRouter, address _bento) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tridentRouter`|`address`|New address for Trident router.|
|`_bento`|`address`|New address for Bento Box.|


## Events
### C3Retired
=== Event Setup ===


```solidity
event C3Retired(
    address indexed retiringAddress,
    address indexed beneficiaryAddress,
    string beneficiaryString,
    string retirementMessage,
    address indexed carbonPool,
    address carbonToken,
    uint retiredAmount
);
```

### PoolAdded

```solidity
event PoolAdded(address indexed carbonPool, address indexed poolRouter, address indexed tridentPool);
```

### PoolRemoved

```solidity
event PoolRemoved(address indexed carbonPool);
```

### PoolRouterChanged

```solidity
event PoolRouterChanged(address indexed carbonPool, address indexed oldRouter, address indexed newRouter);
```

### TridentChanged

```solidity
event TridentChanged(
    address indexed oldBento, address indexed newBento, address indexed oldTrident, address newTrident
);
```

### FeeUpdated

```solidity
event FeeUpdated(uint oldFee, uint newFee);
```

### MasterAggregatorUpdated

```solidity
event MasterAggregatorUpdated(address indexed oldAddress, address indexed newAddress);
```

