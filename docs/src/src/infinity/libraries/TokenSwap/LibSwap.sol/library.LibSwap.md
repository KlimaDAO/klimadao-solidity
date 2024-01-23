# LibSwap
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/libraries/TokenSwap/LibSwap.sol)

**Author:**
Cujo


## Functions
### swapToExactCarbonDefault

Swaps to an exact number of carbon tokens


```solidity
function swapToExactCarbonDefault(address sourceToken, address carbonToken, uint sourceAmount, uint carbonAmount)
    internal
    returns (uint carbonReceived);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sourceToken`|`address`|          Source token provided to swap|
|`carbonToken`|`address`|          Pool token needed|
|`sourceAmount`|`uint256`|         Max amount of the source token|
|`carbonAmount`|`uint256`|         Needed amount of tokens out|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`carbonReceived`|`uint256`|      Pool tokens actually received|


### swapExactSourceToCarbonDefault

Swaps to an exact number of source tokens


```solidity
function swapExactSourceToCarbonDefault(address sourceToken, address carbonToken, uint amount)
    internal
    returns (uint carbonReceived);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sourceToken`|`address`|          Source token provided to swap|
|`carbonToken`|`address`|          Pool token needed|
|`amount`|`uint256`|               Amount of the source token to swap|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`carbonReceived`|`uint256`|      Pool tokens actually received|


### returnTradeDust

Return any dust/slippaged amounts still held by the contract


```solidity
function returnTradeDust(address sourceToken, address poolToken) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sourceToken`|`address`|      Source token provided to swap|
|`poolToken`|`address`|        Pool token used|


### swapToKlimaFromUsdc

Swaps a given amount of USDC for KLIMA using Sushiswap


```solidity
function swapToKlimaFromUsdc(uint sourceAmount, uint klimaAmount) internal returns (uint klimaReceived);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sourceAmount`|`uint256`|     Amount of USDC to swap|
|`klimaAmount`|`uint256`|      Amount of KLIMA to swap for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`klimaReceived`|`uint256`|   Amount of KLIMA received|


### swapToKlimaFromOther

Swaps from arbitrary token routed through USDC for KLIMA


```solidity
function swapToKlimaFromOther(address sourceToken, uint sourceAmount, uint klimaAmount)
    internal
    returns (uint klimaReceived);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sourceToken`|`address`|      Source token provided to swap|
|`sourceAmount`|`uint256`|     Amount of source token to swap|
|`klimaAmount`|`uint256`|      Amount of KLIMA to swap for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`klimaReceived`|`uint256`|   Amount of KLIMA received|


### swapWithRetirementBonds

Performs a swap with Retirement Bonds for carbon to retire.


```solidity
function swapWithRetirementBonds(address sourceToken, address carbonToken, uint sourceAmount, uint carbonAmount)
    internal
    returns (uint carbonRecieved);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sourceToken`|`address`|      Source token provided to swap|
|`carbonToken`|`address`|      Carbon token to receive|
|`sourceAmount`|`uint256`|     Amount of source token to swap|
|`carbonAmount`|`uint256`|     Amount of carbon token needed|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`carbonRecieved`|`uint256`|  Amount of carbon token received from the swap|


### getSourceAmount

Get the source amount needed when swapping within a single DEX


```solidity
function getSourceAmount(address sourceToken, address carbonToken, uint amount)
    internal
    view
    returns (uint sourceNeeded);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sourceToken`|`address`|      Source token provided to swap|
|`carbonToken`|`address`|      Pool token used|
|`amount`|`uint256`|           Amount of carbon tokens needed|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`sourceNeeded`|`uint256`|    Total source tokens needed for output amount|


### getMultipleSourceAmount

Get the source amount needed when swapping between multiple DEXs


```solidity
function getMultipleSourceAmount(address sourceToken, address carbonToken, uint amount)
    internal
    view
    returns (uint[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sourceToken`|`address`|      Source token provided to swap|
|`carbonToken`|`address`|      Pool token used|
|`amount`|`uint256`|           Amount of carbon tokens needed|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[]`|sourcesNeeded    Total source tokens needed for output amount|


### getSourceAmountFromRetirementBond

Fetches the amount of KLIMA needed for a retirement bond, then calculates the source
amount needed if a DEX swap is required.


```solidity
function getSourceAmountFromRetirementBond(address sourceToken, address carbonToken, uint amount)
    internal
    view
    returns (uint sourceNeeded);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sourceToken`|`address`|      Source token provided to swap|
|`carbonToken`|`address`|      Pool token used|
|`amount`|`uint256`|           Amount of carbon tokens needed|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`sourceNeeded`|`uint256`|    Total source tokens needed for output amount|


### getDefaultAmountOut

Get the source amount needed when swapping between multiple DEXs


```solidity
function getDefaultAmountOut(address sourceToken, address carbonToken, uint amount)
    internal
    view
    returns (uint amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sourceToken`|`address`|      Source token provided to swap|
|`carbonToken`|`address`|      Pool token used|
|`amount`|`uint256`|           Amount of carbon tokens needed|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amountOut`|`uint256`|       Amount of carbonTokens recieved for the input amount|


### _performToExactSwap

Perform a toExact swap depending on the dex provided


```solidity
function _performToExactSwap(uint8 dex, address router, address[] memory path, uint maxAmountIn, uint amount)
    private
    returns (uint amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`dex`|`uint8`|          Identifier for which DEX to use|
|`router`|`address`|       Router for the swap|
|`path`|`address[]`|         Trade path to use|
|`maxAmountIn`|`uint256`|  Max amount of source tokens to swap|
|`amount`|`uint256`|       Total pool tokens needed|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amountOut`|`uint256`|   Total pool tokens swapped|


### _performExactSourceSwap

Perform a swap using all source tokens


```solidity
function _performExactSourceSwap(uint8 dex, address router, address[] memory path, uint amount)
    private
    returns (uint amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`dex`|`uint8`|          Identifier for which DEX to use|
|`router`|`address`|       Router for the swap|
|`path`|`address[]`|         Trade path to use|
|`amount`|`uint256`|       Amount of tokens to swap|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amountOut`|`uint256`|   Total pool tokens swapped|


### _getAmountIn

Return the amountIn needed for an exact swap


```solidity
function _getAmountIn(uint8 dex, address router, address[] memory path, uint amount)
    private
    view
    returns (uint amountIn);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`dex`|`uint8`|          Identifier for which DEX to use|
|`router`|`address`|       Router for the swap|
|`path`|`address[]`|         Trade path to use|
|`amount`|`uint256`|       Total pool tokens needed|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amountIn`|`uint256`|    Total pool tokens swapped|


### _getAmountOut

Return the amountIn needed for an exact swap


```solidity
function _getAmountOut(uint8 dex, address router, address[] memory path, uint amount)
    private
    view
    returns (uint amountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`dex`|`uint8`|          Identifier for which DEX to use|
|`router`|`address`|       Router for the swap|
|`path`|`address[]`|         Trade path to use|
|`amount`|`uint256`|       Total source tokens spent|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amountOut`|`uint256`|   Total pool tokens swapped|


