# KeeperBase
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/integrations/sushixklima/keepers/KeeperBase.sol)


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

