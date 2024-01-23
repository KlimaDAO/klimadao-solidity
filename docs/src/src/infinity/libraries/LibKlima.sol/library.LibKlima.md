# LibKlima
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/libraries/LibKlima.sol)

**Author:**
Cujo


## Functions
### toWrappedAmount

Returns wsKLIMA amount for provided sKLIMA amount


```solidity
function toWrappedAmount(uint amount) internal view returns (uint wrappedAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|           sKLIMA provided|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`wrappedAmount`|`uint256`|   wsKLIMA amount|


### toUnwrappedAmount

Returns sKLIMA amount for provided wsKLIMA amount


```solidity
function toUnwrappedAmount(uint amount) internal view returns (uint unwrappedAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|           wsKLIMA provided|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`unwrappedAmount`|`uint256`|   sKLIMA amount|


### unwrapKlima

Unwraps and unstakes provided wsKLIMA amount


```solidity
function unwrapKlima(uint amount) internal returns (uint unwrappedAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|           wsKLIMA provided|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`unwrappedAmount`|`uint256`|   Final KLIMA amount|


### unstakeKlima

Unstakes provided sKLIMA amount


```solidity
function unstakeKlima(uint amount) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|           sKLIMA provided|


### wrapKlima

Stakes and wraps provided KLIMA amount


```solidity
function wrapKlima(uint amount) internal returns (uint wrappedAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|           KLIMA provided|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`wrappedAmount`|`uint256`|   Final wsKLIMA amount|


### stakeKlima

Stakes provided KLIMA amount


```solidity
function stakeKlima(uint amount) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|           KLIMA provided|


