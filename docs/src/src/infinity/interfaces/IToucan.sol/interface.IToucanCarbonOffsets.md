# IToucanCarbonOffsets
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/infinity/interfaces/IToucan.sol)


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

### standardRegistry


```solidity
function standardRegistry() external returns (string memory registry);
```

