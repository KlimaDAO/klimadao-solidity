# Account
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/infinity/AppStorage.sol)

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

