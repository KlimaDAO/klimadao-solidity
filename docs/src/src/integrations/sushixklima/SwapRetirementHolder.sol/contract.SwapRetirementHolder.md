# SwapRetirementHolder
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/integrations/sushixklima/SwapRetirementHolder.sol)

**Inherits:**
[KeeperCompatibleInterface](/src/integrations/sushixklima/keepers/KeeperCompatibleInterface.sol/interface.KeeperCompatibleInterface.md), [Ownable](/src/protocol/staking/utils/KlimaTreasury.sol/contract.Ownable.md)


## State Variables
### interval
Use an interval in seconds and a timestamp to slow execution of Upkeep


```solidity
uint256 public interval;
```


### lastTimeStamp

```solidity
uint256 public lastTimeStamp;
```


### numPendingRetirementAddresses

```solidity
uint256 public numPendingRetirementAddresses;
```


### continueUpKeeping

```solidity
bool private continueUpKeeping;
```


### WrappedNativeAssetAddress

```solidity
address public WrappedNativeAssetAddress;
```


### sourceCarbonToken

```solidity
address public sourceCarbonToken;
```


### KlimaAggregator

```solidity
IKlimaRetirementAggregator public KlimaAggregator;
```


### pendingRetirementAmounts

```solidity
mapping(address => uint256) public pendingRetirementAmounts;
```


### pendingRetirees

```solidity
mapping(uint256 => address) public pendingRetirees;
```


### pendingAddressQueuePosition

```solidity
mapping(address => uint256) public pendingAddressQueuePosition;
```


## Functions
### constructor


```solidity
constructor(address _KlimaAggregator, uint256 _interval, address _wrappedNativeAsset, address _carbonToken);
```

### setKlimaAggregator


```solidity
function setKlimaAggregator(address newAggregator) public onlyManager;
```

### setRetirementInterval


```solidity
function setRetirementInterval(uint256 newInterval) public onlyManager;
```

### setSourceCarbonToken


```solidity
function setSourceCarbonToken(address newCarbonToken) public onlyManager;
```

### checkUpkeep


```solidity
function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory);
```

### performUpkeep


```solidity
function performUpkeep(bytes calldata) external override;
```

### storePendingRetirement


```solidity
function storePendingRetirement(uint256 amountToStore, address addressToStore) public onlyManager;
```

### replaceAddressInPendingRetirement


```solidity
function replaceAddressInPendingRetirement(address oldAddress, address replacementAddress) public onlyManager;
```

### receive


```solidity
receive() external payable;
```

### fallback


```solidity
fallback() external payable;
```

## Events
### intervalUpdated

```solidity
event intervalUpdated(uint256 newInterval);
```

### aggregatorAddressUpdated

```solidity
event aggregatorAddressUpdated(address newAddress);
```

### newPendingRetirement

```solidity
event newPendingRetirement(address retiree, uint256 amount);
```

### newCarbonTokenUpdated

```solidity
event newCarbonTokenUpdated(address newCarbonTokenUpdate);
```

