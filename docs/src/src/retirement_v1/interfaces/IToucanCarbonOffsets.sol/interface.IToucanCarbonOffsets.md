# IToucanCarbonOffsets
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/29fd912e7e35bfd36ad9c6e57c2a312d3aed3640/src/retirement_v1/interfaces/IToucanCarbonOffsets.sol)


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

