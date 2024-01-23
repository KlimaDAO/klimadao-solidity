# KlimaStaking
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/staking/regular/KlimaStaking_v2.sol)

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
uint public totalBonus;
```


### warmupContract

```solidity
address public warmupContract;
```


### warmupPeriod

```solidity
uint public warmupPeriod;
```


### warmupInfo

```solidity
mapping(address => Claim) public warmupInfo;
```


## Functions
### constructor


```solidity
constructor(address _KLIMA, address _sKLIMA, uint _epochLength, uint _firstEpochNumber, uint _firstEpochBlock);
```

### stake

stake KLIMA to enter warmup


```solidity
function stake(uint _amount, address _recipient) external returns (bool);
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
function unstake(uint _amount, bool _trigger) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|uint|
|`_trigger`|`bool`|bool|


### index

returns the sKLIMA index, which tracks rebase growth


```solidity
function index() public view returns (uint);
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
function contractBalance() public view returns (uint);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint|


### giveLockBonus

provide bonus to locked staking contract


```solidity
function giveLockBonus(uint _amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|uint|


### returnLockBonus

reclaim bonus from locked staking contract


```solidity
function returnLockBonus(uint _amount) external;
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
function setWarmup(uint _warmupPeriod) external onlyManager;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_warmupPeriod`|`uint256`|uint|


## Structs
### Epoch

```solidity
struct Epoch {
    uint length;
    uint number;
    uint endBlock;
    uint distribute;
}
```

### Claim

```solidity
struct Claim {
    uint deposit;
    uint gons;
    uint expiry;
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

