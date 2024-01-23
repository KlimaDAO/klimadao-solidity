# testETHSender
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/integrations/sushixklima/TestETHSender.sol)


## State Variables
### retirementHolderAddress

```solidity
address payable public retirementHolderAddress;
```


### sushiAmountOffset

```solidity
uint public sushiAmountOffset;
```


## Functions
### constructor


```solidity
constructor(address retirementHolder, uint sushiAmount);
```

### sendETHToHolder


```solidity
function sendETHToHolder(address payable _to) public payable;
```

