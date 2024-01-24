# Account
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/29fd912e7e35bfd36ad9c6e57c2a312d3aed3640/src/infinity/AppStorage.sol)

**Author:**
Cujo


## Structs
### Retirement

```solidity
struct Retirement {
    address poolTokenAddress;
    address projectTokenAddress;
    address beneficiaryAddress;
    string beneficiary;
    string retirementMessage;
    uint256 amount;
    uint256 pledgeID;
}
```

### State

```solidity
struct State {
    mapping(uint256 => Retirement) retirements;
    mapping(address => uint256) totalPoolRetired;
    mapping(address => uint256) totalProjectRetired;
    uint256 totalRetirements;
    uint256 totalCarbonRetired;
    uint256 totalRewardsClaimed;
}
```

