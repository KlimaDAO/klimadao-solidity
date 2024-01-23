# RetireInfoFacet
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/facets/Retire/RetireInfoFacet.sol)


## Functions
### getTotalRetirements


```solidity
function getTotalRetirements(address account) external view returns (uint totalRetirements);
```

### getTotalCarbonRetired


```solidity
function getTotalCarbonRetired(address account) external view returns (uint totalCarbonRetired);
```

### getTotalPoolRetired


```solidity
function getTotalPoolRetired(address account, address poolToken) external view returns (uint totalPoolRetired);
```

### getTotalProjectRetired


```solidity
function getTotalProjectRetired(address account, address projectToken) external view returns (uint);
```

### getTotalRewardsClaimed


```solidity
function getTotalRewardsClaimed(address account) external view returns (uint totalClaimed);
```

### getRetirementDetails


```solidity
function getRetirementDetails(address account, uint retirementIndex)
    external
    view
    returns (
        address poolTokenAddress,
        address projectTokenAddress,
        address beneficiaryAddress,
        string memory beneficiary,
        string memory retirementMessage,
        uint amount
    );
```

