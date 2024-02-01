# RetirementQuoter
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/704b462e69030cb9a43680057bee91d745d579ba/src/infinity/facets/RetirementQuoter.sol)

**Author:**
Cujo


## State Variables
### s

```solidity
AppStorage internal s;
```


## Functions
### getSourceAmountSwapOnly


```solidity
function getSourceAmountSwapOnly(address sourceToken, address carbonToken, uint256 amountOut)
    public
    view
    returns (uint256 amountIn);
```

### getSourceAmountDefaultRetirement


```solidity
function getSourceAmountDefaultRetirement(address sourceToken, address carbonToken, uint256 retireAmount)
    public
    view
    returns (uint256 amountIn);
```

### getSourceAmountSpecificRetirement


```solidity
function getSourceAmountSpecificRetirement(address sourceToken, address carbonToken, uint256 retireAmount)
    public
    view
    returns (uint256 amountIn);
```

### getSourceAmountDefaultRedeem


```solidity
function getSourceAmountDefaultRedeem(address sourceToken, address carbonToken, uint256 redeemAmount)
    public
    view
    returns (uint256 amountIn);
```

### getSourceAmountSpecificRedeem


```solidity
function getSourceAmountSpecificRedeem(address sourceToken, address carbonToken, uint256[] memory redeemAmounts)
    public
    view
    returns (uint256 amountIn);
```

### getRetireAmountSourceDefault


```solidity
function getRetireAmountSourceDefault(address sourceToken, address carbonToken, uint256 amount)
    public
    view
    returns (uint256 amountOut);
```

### getRetireAmountSourceSpecific


```solidity
function getRetireAmountSourceSpecific(address sourceToken, address carbonToken, uint256 amount)
    public
    view
    returns (uint256 amountOut);
```

