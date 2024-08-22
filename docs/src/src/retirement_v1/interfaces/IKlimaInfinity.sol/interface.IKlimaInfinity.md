# IKlimaInfinity
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/retirement_v1/interfaces/IKlimaInfinity.sol)


## Functions
### retireExactCarbonDefault


```solidity
function retireExactCarbonDefault(
    address sourceToken,
    address poolToken,
    uint256 maxAmountIn,
    uint256 retireAmount,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external payable returns (uint256 retirementIndex);
```

### retireExactCarbonSpecific


```solidity
function retireExactCarbonSpecific(
    address sourceToken,
    address poolToken,
    address projectToken,
    uint256 maxAmountIn,
    uint256 retireAmount,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external payable returns (uint256 retirementIndex);
```

### retireExactSourceDefault


```solidity
function retireExactSourceDefault(
    address sourceToken,
    address poolToken,
    uint256 maxAmountIn,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external payable returns (uint256 retirementIndex);
```

### retireExactSourceSpecific


```solidity
function retireExactSourceSpecific(
    address sourceToken,
    address poolToken,
    address projectToken,
    uint256 maxAmountIn,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external payable returns (uint256 retirementIndex);
```

### getSourceAmountDefaultRetirement


```solidity
function getSourceAmountDefaultRetirement(address sourceToken, address carbonToken, uint256 retireAmount)
    external
    view
    returns (uint256 amountIn);
```

### getSourceAmountSpecificRetirement


```solidity
function getSourceAmountSpecificRetirement(address sourceToken, address carbonToken, uint256 retireAmount)
    external
    view
    returns (uint256 amountIn);
```

### getRetireAmountSourceDefault


```solidity
function getRetireAmountSourceDefault(address sourceToken, address carbonToken, uint256 amount)
    external
    view
    returns (uint256 amountOut);
```

### getRetireAmountSourceSpecific


```solidity
function getRetireAmountSourceSpecific(address sourceToken, address carbonToken, uint256 amount)
    external
    view
    returns (uint256 amountOut);
```

