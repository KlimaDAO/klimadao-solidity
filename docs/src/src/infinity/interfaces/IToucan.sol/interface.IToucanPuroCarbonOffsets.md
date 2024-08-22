# IToucanPuroCarbonOffsets
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/infinity/interfaces/IToucan.sol)


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

