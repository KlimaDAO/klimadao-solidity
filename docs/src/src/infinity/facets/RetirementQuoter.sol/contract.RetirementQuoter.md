# RetirementQuoter
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/facets/RetirementQuoter.sol)

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
function getSourceAmountSwapOnly(address sourceToken, address carbonToken, uint amountOut)
    public
    view
    returns (uint amountIn);
```

### getSourceAmountDefaultRetirement


```solidity
function getSourceAmountDefaultRetirement(address sourceToken, address carbonToken, uint retireAmount)
    public
    view
    returns (uint amountIn);
```

### getSourceAmountSpecificRetirement


```solidity
function getSourceAmountSpecificRetirement(address sourceToken, address carbonToken, uint retireAmount)
    public
    view
    returns (uint amountIn);
```

### getSourceAmountDefaultRedeem


```solidity
function getSourceAmountDefaultRedeem(address sourceToken, address carbonToken, uint redeemAmount)
    public
    view
    returns (uint amountIn);
```

### getSourceAmountSpecificRedeem


```solidity
function getSourceAmountSpecificRedeem(address sourceToken, address carbonToken, uint[] memory redeemAmounts)
    public
    view
    returns (uint amountIn);
```

### getRetireAmountSourceDefault


```solidity
function getRetireAmountSourceDefault(address sourceToken, address carbonToken, uint amount)
    public
    view
    returns (uint amountOut);
```

### getRetireAmountSourceSpecific


```solidity
function getRetireAmountSourceSpecific(address sourceToken, address carbonToken, uint amount)
    public
    view
    returns (uint amountOut);
```

