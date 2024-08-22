# KeeperBase
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/integrations/sushixklima/keepers/KeeperBase.sol)


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

