# KeeperBase
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/integrations/sushixklima/keepers/KeeperBase.sol)


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

