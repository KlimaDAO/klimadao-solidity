# ITridentPool
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/retirement_v1/interfaces/ITridentPool.sol)

Trident pool interface.


## Functions
### getAmountOut

Simulates a trade and returns the expected output.

*The pool does not need to include a trade simulator directly in itself - it can use a library.*


```solidity
function getAmountOut(bytes calldata data) external view returns (uint finalAmountOut);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`data`|`bytes`|ABI-encoded params that the pool requires.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`finalAmountOut`|`uint256`|The amount of output tokens that will be sent to the user if the trade is executed.|


### getAmountIn

Simulates a trade and returns the expected output.

*The pool does not need to include a trade simulator directly in itself - it can use a library.*


```solidity
function getAmountIn(bytes calldata data) external view returns (uint finalAmountIn);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`data`|`bytes`|ABI-encoded params that the pool requires.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`finalAmountIn`|`uint256`|The amount of input tokens that are required from the user if the trade is executed.|


