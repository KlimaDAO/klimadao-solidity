# IRetireToucanCarbon
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/retirement_v1/interfaces/IRetireToucanCarbon.sol)


## Functions
### retireToucan


```solidity
function retireToucan(
    address _sourceToken,
    address _poolToken,
    uint256 _amount,
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
    uint256 _amount,
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
function getNeededBuyAmount(address _sourceToken, address _poolToken, uint256 _poolAmount, bool _retireSpecific)
    external
    view
    returns (uint256, uint256);
```

