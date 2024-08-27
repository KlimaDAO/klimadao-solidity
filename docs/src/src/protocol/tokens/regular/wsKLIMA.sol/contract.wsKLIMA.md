# wsKLIMA
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/protocol/tokens/regular/wsKLIMA.sol)

**Inherits:**
[ERC20](/src/protocol/tokens/regular/KlimaToken.sol/abstract.ERC20.md)


## State Variables
### sKLIMA

```solidity
address public immutable sKLIMA;
```


## Functions
### constructor


```solidity
constructor(address _sKLIMA) ERC20("Wrapped sKLIMA", "wsKLIMA");
```

### wrap

wrap sKLIMA


```solidity
function wrap(uint256 _amount) external returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|uint|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint|


### unwrap

unwrap sKLIMA


```solidity
function unwrap(uint256 _amount) external returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|uint|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint|


### wKLIMATosKLIMA

converts wKLIMA amount to sKLIMA


```solidity
function wKLIMATosKLIMA(uint256 _amount) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|uint|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint|


### sKLIMATowKLIMA

converts sKLIMA amount to wKLIMA


```solidity
function sKLIMATowKLIMA(uint256 _amount) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|uint|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint|


