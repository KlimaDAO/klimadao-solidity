# testETHSender
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/integrations/sushixklima/TestETHSender.sol)


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

