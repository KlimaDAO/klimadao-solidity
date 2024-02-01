# IToucanCarbonOffsets
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/infinity/interfaces/IToucan.sol)


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

