# Distributor
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/staking/regular/KlimaStakingDistributor_v4.sol)

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
uint public immutable epochLength;
```


### nextEpochBlock

```solidity
uint public nextEpochBlock;
```


### adjustments

```solidity
mapping(uint => Adjust) public adjustments;
```


### info

```solidity
Info[] public info;
```


## Functions
### constructor


```solidity
constructor(address _treasury, address _klima, uint _epochLength, uint _nextEpochBlock);
```

### distribute

send epoch reward to staking contract


```solidity
function distribute() external returns (bool);
```

### adjust

increment reward rate for collector


```solidity
function adjust(uint _index) internal;
```

### nextRewardAt

view function for next reward at given rate


```solidity
function nextRewardAt(uint _rate) public view returns (uint);
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
function nextRewardFor(address _recipient) public view returns (uint);
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
function addRecipient(address _recipient, uint _rewardRate) external onlyPolicy;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_recipient`|`address`|address|
|`_rewardRate`|`uint256`|uint|


### removeRecipient

removes recipient for distributions


```solidity
function removeRecipient(uint _index, address _recipient) external onlyPolicy;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint256`|uint|
|`_recipient`|`address`|address|


### setAdjustment

set adjustment info for a collector's reward rate


```solidity
function setAdjustment(uint _index, bool _add, uint _rate, uint _target) external onlyPolicy;
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
    uint rate;
    address recipient;
}
```

### Adjust

```solidity
struct Adjust {
    bool add;
    uint rate;
    uint target;
}
```

