# IToucanPuroCarbonOffsets
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/infinity/interfaces/IToucan.sol)


## Functions
### requestRetirement


```solidity
function requestRetirement(CreateRetirementRequestParams calldata params) external returns (uint256 requestId);
```

## Structs
### CreateRetirementRequestParams

```solidity
struct CreateRetirementRequestParams {
    uint256[] tokenIds;
    uint256 amount;
    string retiringEntityString;
    address beneficiary;
    string beneficiaryString;
    string retirementMessage;
    string beneficiaryLocation;
    string consumptionCountryCode;
    uint256 consumptionPeriodStart;
    uint256 consumptionPeriodEnd;
}
```

