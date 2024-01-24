# Distributor
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/29fd912e7e35bfd36ad9c6e57c2a312d3aed3640/src/protocol/staking/regular/KlimaStakingDistributor_v4.sol)

**Inherits:**
[Policy](/src/protocol/staking/regular/KlimaStakingDistributor_v4.sol/contract.Policy.md)


## State Variables
### KLIMA

```solidity
address public immutable KLIMA;
```


### treasury

```solidity
address public immutable treasury;
```


### epochLength

```solidity
uint256 public immutable epochLength;
```


### nextEpochBlock

```solidity
uint256 public nextEpochBlock;
```


### adjustments

```solidity
mapping(uint256 => Adjust) public adjustments;
```


### info

```solidity
Info[] public info;
```


## Functions
### constructor


```solidity
constructor(address _treasury, address _klima, uint256 _epochLength, uint256 _nextEpochBlock);
```

### distribute

send epoch reward to staking contract


```solidity
function distribute() external returns (bool);
```

### adjust

increment reward rate for collector


```solidity
function adjust(uint256 _index) internal;
```

### nextRewardAt

view function for next reward at given rate


```solidity
function nextRewardAt(uint256 _rate) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_rate`|`uint256`|uint|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint|


### nextRewardFor

view function for next reward for specified address


```solidity
function nextRewardFor(address _recipient) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_recipient`|`address`|address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint|


### addRecipient

adds recipient for distributions


```solidity
function addRecipient(address _recipient, uint256 _rewardRate) external onlyPolicy;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_recipient`|`address`|address|
|`_rewardRate`|`uint256`|uint|


### removeRecipient

removes recipient for distributions


```solidity
function removeRecipient(uint256 _index, address _recipient) external onlyPolicy;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint256`|uint|
|`_recipient`|`address`|address|


### setAdjustment

set adjustment info for a collector's reward rate


```solidity
function setAdjustment(uint256 _index, bool _add, uint256 _rate, uint256 _target) external onlyPolicy;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint256`|uint|
|`_add`|`bool`|bool|
|`_rate`|`uint256`|uint|
|`_target`|`uint256`|uint|


## Structs
### Info

```solidity
struct Info {
    uint256 rate;
    address recipient;
}
```

### Adjust

```solidity
struct Adjust {
    bool add;
    uint256 rate;
    uint256 target;
}
```

