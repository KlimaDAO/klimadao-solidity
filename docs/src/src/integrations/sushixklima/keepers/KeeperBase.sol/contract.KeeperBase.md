# KeeperBase
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/integrations/sushixklima/keepers/KeeperBase.sol)


## Functions
### preventExecution

method that allows it to be simulated via eth_call by checking that
the sender is the zero address.


```solidity
function preventExecution() internal view;
```

### cannotExecute

modifier that allows it to be simulated via eth_call by checking
that the sender is the zero address.


```solidity
modifier cannotExecute();
```

## Errors
### OnlySimulatedBackend

```solidity
error OnlySimulatedBackend();
```

