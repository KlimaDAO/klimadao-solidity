# IKlimaInfinity
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/interfaces/IKlimaInfinity.sol)


## Functions
### toucan_retireExactCarbonPoolDefault


```solidity
function toucan_retireExactCarbonPoolDefault(
    address sourceToken,
    address carbonToken,
    uint amount,
    address retiringAddress,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external returns (uint retirementIndex);
```

### toucan_retireExactCarbonPoolWithEntityDefault


```solidity
function toucan_retireExactCarbonPoolWithEntityDefault(
    address sourceToken,
    address carbonToken,
    uint amount,
    address retiringAddress,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external returns (uint retirementIndex);
```

### toucan_retireExactSourcePoolDefault


```solidity
function toucan_retireExactSourcePoolDefault(
    address sourceToken,
    address carbonToken,
    uint amount,
    address retiringAddress,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external returns (uint retirementIndex);
```

### toucan_retireExactSourcePoolWithEntityDefault


```solidity
function toucan_retireExactSourcePoolWithEntityDefault(
    address sourceToken,
    address carbonToken,
    uint amount,
    address retiringAddress,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external returns (uint retirementIndex);
```

### toucan_retireExactCarbonPoolSpecific


```solidity
function toucan_retireExactCarbonPoolSpecific(
    address sourceToken,
    address carbonToken,
    address projectToken,
    uint amount,
    address retiringAddress,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external returns (uint retirementIndex);
```

### toucan_retireExactCarbonPoolWithEntitySpecific


```solidity
function toucan_retireExactCarbonPoolWithEntitySpecific(
    address sourceToken,
    address poolToken,
    address projectToken,
    uint amount,
    address retiringAddress,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external returns (uint retirementIndex);
```

### toucan_retireExactSourcePoolWithEntitySpecific


```solidity
function toucan_retireExactSourcePoolWithEntitySpecific(
    address sourceToken,
    address poolToken,
    address projectToken,
    uint sourceAmount,
    address retiringAddress,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external returns (uint retirementIndex);
```

### toucan_retireExactSourcePoolSpecific


```solidity
function toucan_retireExactSourcePoolSpecific(
    address sourceToken,
    address poolToken,
    address projectToken,
    uint sourceAmount,
    address retiringAddress,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external returns (uint retirementIndex);
```

### moss_retireExactCarbonPoolDefault


```solidity
function moss_retireExactCarbonPoolDefault(
    address sourceToken,
    address carbonToken,
    uint amount,
    address retiringAddress,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external returns (uint retirementIndex);
```

### moss_retireExactCarbonPoolWithEntityDefault


```solidity
function moss_retireExactCarbonPoolWithEntityDefault(
    address sourceToken,
    address carbonToken,
    uint amount,
    address retiringAddress,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external returns (uint retirementIndex);
```

### moss_retireExactSourcePoolDefault


```solidity
function moss_retireExactSourcePoolDefault(
    address sourceToken,
    address carbonToken,
    uint sourceAmount,
    address retiringAddress,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external returns (uint retirementIndex);
```

### moss_retireExactSourcePoolWithEntityDefault


```solidity
function moss_retireExactSourcePoolWithEntityDefault(
    address sourceToken,
    address carbonToken,
    uint sourceAmount,
    address retiringAddress,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external returns (uint retirementIndex);
```

### c3_retireExactCarbonPoolDefault


```solidity
function c3_retireExactCarbonPoolDefault(
    address sourceToken,
    address carbonToken,
    uint amount,
    address retiringAddress,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external returns (uint retirementIndex);
```

### c3_retireExactCarbonPoolWithEntityDefault


```solidity
function c3_retireExactCarbonPoolWithEntityDefault(
    address sourceToken,
    address carbonToken,
    uint amount,
    address retiringAddress,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external returns (uint retirementIndex);
```

### c3_retireExactSourcePoolDefault


```solidity
function c3_retireExactSourcePoolDefault(
    address sourceToken,
    address carbonToken,
    uint sourceAmount,
    address retiringAddress,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external returns (uint retirementIndex);
```

### c3_retireExactSourcePoolWithEntityDefault


```solidity
function c3_retireExactSourcePoolWithEntityDefault(
    address sourceToken,
    address carbonToken,
    uint sourceAmount,
    address retiringAddress,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external returns (uint retirementIndex);
```

### c3_retireExactCarbonPoolSpecific


```solidity
function c3_retireExactCarbonPoolSpecific(
    address sourceToken,
    address carbonToken,
    address projectToken,
    uint amount,
    address retiringAddress,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external returns (uint retirementIndex);
```

### c3_retireExactCarbonPoolWithEntitySpecific


```solidity
function c3_retireExactCarbonPoolWithEntitySpecific(
    address sourceToken,
    address poolToken,
    address projectToken,
    uint amount,
    address retiringAddress,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external returns (uint retirementIndex);
```

### c3_retireExactSourcePoolWithEntitySpecific


```solidity
function c3_retireExactSourcePoolWithEntitySpecific(
    address sourceToken,
    address poolToken,
    address projectToken,
    uint sourceAmount,
    address retiringAddress,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external returns (uint retirementIndex);
```

### c3_retireExactSourcePoolSpecific


```solidity
function c3_retireExactSourcePoolSpecific(
    address sourceToken,
    address poolToken,
    address projectToken,
    uint sourceAmount,
    address retiringAddress,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external returns (uint retirementIndex);
```

