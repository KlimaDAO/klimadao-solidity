# IRetireC3Carbon
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/retirement_v1/interfaces/IRetireC3Carbon.sol)


## Functions
### retireC3


```solidity
function retireC3(
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

### retireC3Specific


```solidity
function retireC3Specific(
    address _sourceToken,
    address _poolToken,
    uint _amount,
    bool _amountInCarbon,
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

