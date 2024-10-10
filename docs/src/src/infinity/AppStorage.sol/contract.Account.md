# Account
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/infinity/AppStorage.sol)

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

