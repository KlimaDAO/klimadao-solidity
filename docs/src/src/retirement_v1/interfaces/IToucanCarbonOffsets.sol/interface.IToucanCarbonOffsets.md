# IToucanCarbonOffsets
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/retirement_v1/interfaces/IToucanCarbonOffsets.sol)


## Functions
### retire


```solidity
function retire(uint amount) external;
```

### retireAndMintCertificate


```solidity
function retireAndMintCertificate(
    string calldata retiringEntityString,
    address beneficiary,
    string calldata beneficiaryString,
    string calldata retirementMessage,
    uint amount
) external;
```

### mintCertificateLegacy


```solidity
function mintCertificateLegacy(
    string calldata retiringEntityString,
    address beneficiary,
    string calldata beneficiaryString,
    string calldata retirementMessage,
    uint amount
) external;
```

