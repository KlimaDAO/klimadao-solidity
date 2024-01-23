# IRetireToucanCarbon
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/retirement_v1/interfaces/IRetireToucanCarbon.sol)


## Functions
### retireToucan


```solidity
function retireToucan(
    address _sourceToken,
    address _poolToken,
    uint _amount,
    bool _amountInCarbon,
    string memory _retireEntityString,
    address _beneficiaryAddress,
    string memory _beneficiaryString,
    string memory _retirementMessage,
    address _retiree
) external;
```

### retireToucanSpecific


```solidity
function retireToucanSpecific(
    address _sourceToken,
    address _poolToken,
    uint _amount,
    bool _amountInCarbon,
    string memory _retireEntityString,
    address _beneficiaryAddress,
    string memory _beneficiaryString,
    string memory _retirementMessage,
    address _retiree,
    address[] memory _carbonList
) external;
```

### getNeededBuyAmount


```solidity
function getNeededBuyAmount(address _sourceToken, address _poolToken, uint _poolAmount, bool _retireSpecific)
    external
    view
    returns (uint, uint);
```

