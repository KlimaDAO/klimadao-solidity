# LibKlima
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/infinity/libraries/LibKlima.sol)

**Author:**
Cujo


## Functions
### toWrappedAmount

Returns wsKLIMA amount for provided sKLIMA amount


```solidity
function toWrappedAmount(uint256 amount) internal view returns (uint256 wrappedAmount);
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
function toUnwrappedAmount(uint256 amount) internal view returns (uint256 unwrappedAmount);
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
function unwrapKlima(uint256 amount) internal returns (uint256 unwrappedAmount);
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
function unstakeKlima(uint256 amount) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|           sKLIMA provided|


### wrapKlima

Stakes and wraps provided KLIMA amount


```solidity
function wrapKlima(uint256 amount) internal returns (uint256 wrappedAmount);
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
function stakeKlima(uint256 amount) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|           KLIMA provided|


