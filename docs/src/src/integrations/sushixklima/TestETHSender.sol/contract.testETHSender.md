# testETHSender
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/integrations/sushixklima/TestETHSender.sol)


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

