# IKlimaCarbonRetirements
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/retirement_v1/interfaces/IKlimaCarbonRetirements.sol)


## Functions
### carbonRetired


```solidity
function carbonRetired(
    address _retiree,
    address _pool,
    uint256 _amount,
    string calldata _beneficiaryString,
    string calldata _retirementMessage
) external;
```

### getUnclaimedTotal


```solidity
function getUnclaimedTotal(address _minter) external view returns (uint256);
```

### offsetClaimed


```solidity
function offsetClaimed(address _minter, uint256 _amount) external returns (bool);
```

### getRetirementIndexInfo


```solidity
function getRetirementIndexInfo(address _retiree, uint256 _index)
    external
    view
    returns (address, uint256, string memory, string memory);
```

### getRetirementPoolInfo


```solidity
function getRetirementPoolInfo(address _retiree, address _pool) external view returns (uint256);
```

### getRetirementTotals


```solidity
function getRetirementTotals(address _retiree) external view returns (uint256, uint256, uint256);
```

