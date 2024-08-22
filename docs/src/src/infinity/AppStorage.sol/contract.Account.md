# Account
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/infinity/AppStorage.sol)

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

