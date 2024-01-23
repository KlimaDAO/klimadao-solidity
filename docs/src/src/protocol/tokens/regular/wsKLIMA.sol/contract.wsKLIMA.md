# wsKLIMA
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/tokens/regular/wsKLIMA.sol)

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
function wrap(uint _amount) external returns (uint);
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
function unwrap(uint _amount) external returns (uint);
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
function wKLIMATosKLIMA(uint _amount) public view returns (uint);
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
function sKLIMATowKLIMA(uint _amount) public view returns (uint);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|uint|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint|


