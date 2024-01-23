# KeeperCompatibleInterface
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/integrations/sushixklima/keepers/KeeperCompatibleInterface.sol)


## Functions
### checkUpkeep

method that is simulated by the keepers to see if any work actually
needs to be performed. This method does does not actually need to be
executable, and since it is only ever simulated it can consume lots of gas.

*To ensure that it is never called, you may want to add the
cannotExecute modifier from KeeperBase to your implementation of this
method.*


```solidity
function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`checkData`|`bytes`|specified in the upkeep registration so it is always the same for a registered upkeep. This can easily be broken down into specific arguments using `abi.decode`, so multiple upkeeps can be registered on the same contract and easily differentiated by the contract.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`upkeepNeeded`|`bool`|boolean to indicate whether the keeper should call performUpkeep or not.|
|`performData`|`bytes`|bytes that the keeper should call performUpkeep with, if upkeep is needed. If you would like to encode data to decode later, try `abi.encode`.|


### performUpkeep

method that is actually executed by the keepers, via the registry.
The data returned by the checkUpkeep simulation will be passed into
this method to actually be executed.

*The input to this method should not be trusted, and the caller of the
method should not even be restricted to any single registry. Anyone should
be able call it, and the input should be validated, there is no guarantee
that the data passed in is the performData returned from checkUpkeep. This
could happen due to malicious keepers, racing keepers, or simply a state
change while the performUpkeep transaction is waiting for confirmation.
Always validate the data passed in.*


```solidity
function performUpkeep(bytes calldata performData) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`performData`|`bytes`|is the data which was passed back from the checkData simulation. If it is encoded, it can easily be decoded into other types by calling `abi.decode`. This data should not be trusted, and should be validated against the contract's current state.|


