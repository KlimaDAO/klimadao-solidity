# IRetireC3Carbon
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/704b462e69030cb9a43680057bee91d745d579ba/src/retirement_v1/interfaces/IRetireC3Carbon.sol)


## Functions
### retireC3


```solidity
function retireC3(
    address _sourceToken,
    address _poolToken,
    uint256 _amount,
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
    uint256 _amount,
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
function getNeededBuyAmount(address _sourceToken, address _poolToken, uint256 _poolAmount, bool _retireSpecific)
    external
    view
    returns (uint256, uint256);
```

