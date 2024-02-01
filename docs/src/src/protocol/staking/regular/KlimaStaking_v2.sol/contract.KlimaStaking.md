# KlimaStaking
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/704b462e69030cb9a43680057bee91d745d579ba/src/protocol/staking/regular/KlimaStaking_v2.sol)

**Inherits:**
[Ownable](/src/protocol/staking/regular/KlimaStaking_v2.sol/contract.Ownable.md)


## State Variables
### KLIMA

```solidity
address public immutable KLIMA;
```


### sKLIMA

```solidity
address public immutable sKLIMA;
```


### epoch

```solidity
Epoch public epoch;
```


### distributor

```solidity
address public distributor;
```


### locker

```solidity
address public locker;
```


### totalBonus

```solidity
uint256 public totalBonus;
```


### warmupContract

```solidity
address public warmupContract;
```


### warmupPeriod

```solidity
uint256 public warmupPeriod;
```


### warmupInfo

```solidity
mapping(address => Claim) public warmupInfo;
```


## Functions
### constructor


```solidity
constructor(address _KLIMA, address _sKLIMA, uint256 _epochLength, uint256 _firstEpochNumber, uint256 _firstEpochBlock);
```

### stake

stake KLIMA to enter warmup


```solidity
function stake(uint256 _amount, address _recipient) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|uint|
|`_recipient`|`address`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool|


### claim

retrieve sKLIMA from warmup


```solidity
function claim(address _recipient) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_recipient`|`address`|address|


### forfeit

forfeit sKLIMA in warmup and retrieve KLIMA


```solidity
function forfeit() external;
```

### toggleDepositLock

prevent new deposits to address (protection from malicious activity)


```solidity
function toggleDepositLock() external;
```

### unstake

redeem sKLIMA for KLIMA


```solidity
function unstake(uint256 _amount, bool _trigger) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|uint|
|`_trigger`|`bool`|bool|


### index

returns the sKLIMA index, which tracks rebase growth


```solidity
function index() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint|


### rebase

trigger rebase if epoch over


```solidity
function rebase() public;
```

### contractBalance

returns contract KLIMA holdings, including bonuses provided


```solidity
function contractBalance() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint|


### giveLockBonus

provide bonus to locked staking contract


```solidity
function giveLockBonus(uint256 _amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|uint|


### returnLockBonus

reclaim bonus from locked staking contract


```solidity
function returnLockBonus(uint256 _amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|uint|


### setContract

sets the contract address for LP staking


```solidity
function setContract(CONTRACTS _contract, address _address) external onlyManager;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_contract`|`CONTRACTS`|address|
|`_address`|`address`||


### setWarmup

set warmup period for new stakers


```solidity
function setWarmup(uint256 _warmupPeriod) external onlyManager;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_warmupPeriod`|`uint256`|uint|


## Structs
### Epoch

```solidity
struct Epoch {
    uint256 length;
    uint256 number;
    uint256 endBlock;
    uint256 distribute;
}
```

### Claim

```solidity
struct Claim {
    uint256 deposit;
    uint256 gons;
    uint256 expiry;
    bool lock;
}
```

## Enums
### CONTRACTS

```solidity
enum CONTRACTS {
    DISTRIBUTOR,
    WARMUP,
    LOCKER
}
```

