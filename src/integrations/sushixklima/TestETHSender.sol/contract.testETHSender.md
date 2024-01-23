# testETHSender
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/integrations/sushixklima/TestETHSender.sol)


## State Variables
### retirementHolderAddress

```solidity
address payable public retirementHolderAddress;
```


### sushiAmountOffset

```solidity
uint256 public sushiAmountOffset;
```


## Functions
### constructor


```solidity
constructor(address retirementHolder, uint256 sushiAmount);
```

### sendETHToHolder


```solidity
function sendETHToHolder(address payable _to) public payable;
```

