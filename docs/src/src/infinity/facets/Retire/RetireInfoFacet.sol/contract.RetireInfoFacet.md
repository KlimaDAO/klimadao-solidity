# RetireInfoFacet
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/704b462e69030cb9a43680057bee91d745d579ba/src/infinity/facets/Retire/RetireInfoFacet.sol)


## Functions
### getTotalRetirements


```solidity
function getTotalRetirements(address account) external view returns (uint256 totalRetirements);
```

### getTotalCarbonRetired


```solidity
function getTotalCarbonRetired(address account) external view returns (uint256 totalCarbonRetired);
```

### getTotalPoolRetired


```solidity
function getTotalPoolRetired(address account, address poolToken) external view returns (uint256 totalPoolRetired);
```

### getTotalProjectRetired


```solidity
function getTotalProjectRetired(address account, address projectToken) external view returns (uint256);
```

### getTotalRewardsClaimed


```solidity
function getTotalRewardsClaimed(address account) external view returns (uint256 totalClaimed);
```

### getRetirementDetails


```solidity
function getRetirementDetails(address account, uint256 retirementIndex)
    external
    view
    returns (
        address poolTokenAddress,
        address projectTokenAddress,
        address beneficiaryAddress,
        string memory beneficiary,
        string memory retirementMessage,
        uint256 amount
    );
```

