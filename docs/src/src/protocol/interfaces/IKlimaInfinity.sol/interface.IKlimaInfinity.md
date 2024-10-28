# IKlimaInfinity
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/protocol/interfaces/IKlimaInfinity.sol)


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

### getSourceAmountSwapOnly


```solidity
function getSourceAmountSwapOnly(address sourceToken, address carbonToken, uint256 amountOut)
    external
    view
    returns (uint256 amountIn);
```

