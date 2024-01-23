# IRetireMossCarbon
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/retirement_v1/interfaces/IRetireMossCarbon.sol)


## Functions
### retireMoss


```solidity
function retireMoss(
    address _sourceToken,
    address _poolToken,
    uint _amount,
    bool _amountInCarbon,
    address _beneficiaryAddress,
    string memory _beneficiaryString,
    string memory _retirementMessage,
    address _retiree
) external;
```

### getNeededBuyAmount


```solidity
function getNeededBuyAmount(address _sourceToken, address _poolToken, uint _poolAmount, bool _retireSpecific)
    external
    view
    returns (uint, uint);
```

