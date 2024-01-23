# IKlimaCarbonRetirements
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/interfaces/IKlimaCarbonRetirements.sol)


## Functions
### carbonRetired


```solidity
function carbonRetired(
    address _retiree,
    address _pool,
    uint _amount,
    string calldata _beneficiaryString,
    string calldata _retirementMessage
) external;
```

### getUnclaimedTotal


```solidity
function getUnclaimedTotal(address _minter) external view returns (uint);
```

### offsetClaimed


```solidity
function offsetClaimed(address _minter, uint _amount) external returns (bool);
```

### getRetirementIndexInfo


```solidity
function getRetirementIndexInfo(address _retiree, uint _index)
    external
    view
    returns (address, uint, string memory, string memory);
```

### getRetirementPoolInfo


```solidity
function getRetirementPoolInfo(address _retiree, address _pool) external view returns (uint);
```

### getRetirementTotals


```solidity
function getRetirementTotals(address _retiree) external view returns (uint, uint, uint);
```

