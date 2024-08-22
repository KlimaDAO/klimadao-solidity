# IToucanCarbonOffsets
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/retirement_v1/interfaces/IToucanCarbonOffsets.sol)


## Functions
### retire


```solidity
function retire(uint256 amount) external;
```

### retireAndMintCertificate


```solidity
function retireAndMintCertificate(
    string calldata retiringEntityString,
    address beneficiary,
    string calldata beneficiaryString,
    string calldata retirementMessage,
    uint256 amount
) external;
```

### mintCertificateLegacy


```solidity
function mintCertificateLegacy(
    string calldata retiringEntityString,
    address beneficiary,
    string calldata beneficiaryString,
    string calldata retirementMessage,
    uint256 amount
) external;
```

