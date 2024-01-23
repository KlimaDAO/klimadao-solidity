# Account
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/AppStorage.sol)

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
    uint amount;
    uint pledgeID;
}
```

### State

```solidity
struct State {
    mapping(uint => Retirement) retirements;
    mapping(address => uint) totalPoolRetired;
    mapping(address => uint) totalProjectRetired;
    uint totalRetirements;
    uint totalCarbonRetired;
    uint totalRewardsClaimed;
}
```

