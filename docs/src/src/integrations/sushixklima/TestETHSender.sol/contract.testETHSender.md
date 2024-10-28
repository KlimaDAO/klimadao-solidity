# testETHSender
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/integrations/sushixklima/TestETHSender.sol)


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

