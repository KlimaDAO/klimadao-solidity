# IKlimaInfinity
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/interfaces/IKlimaInfinity.sol)


## Functions
### retireExactCarbonDefault


```solidity
function retireExactCarbonDefault(
    address sourceToken,
    address poolToken,
    uint maxAmountIn,
    uint retireAmount,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external payable returns (uint retirementIndex);
```

### retireExactCarbonSpecific


```solidity
function retireExactCarbonSpecific(
    address sourceToken,
    address poolToken,
    address projectToken,
    uint maxAmountIn,
    uint retireAmount,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external payable returns (uint retirementIndex);
```

### retireExactSourceDefault


```solidity
function retireExactSourceDefault(
    address sourceToken,
    address poolToken,
    uint maxAmountIn,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external payable returns (uint retirementIndex);
```

### retireExactSourceSpecific


```solidity
function retireExactSourceSpecific(
    address sourceToken,
    address poolToken,
    address projectToken,
    uint maxAmountIn,
    string memory retiringEntityString,
    address beneficiaryAddress,
    string memory beneficiaryString,
    string memory retirementMessage,
    uint8 fromMode
) external payable returns (uint retirementIndex);
```

### getSourceAmountDefaultRetirement


```solidity
function getSourceAmountDefaultRetirement(address sourceToken, address carbonToken, uint retireAmount)
    external
    view
    returns (uint amountIn);
```

### getSourceAmountSpecificRetirement


```solidity
function getSourceAmountSpecificRetirement(address sourceToken, address carbonToken, uint retireAmount)
    external
    view
    returns (uint amountIn);
```

### getSourceAmountSwapOnly


```solidity
function getSourceAmountSwapOnly(address sourceToken, address carbonToken, uint amountOut)
    external
    view
    returns (uint amountIn);
```

