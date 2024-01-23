# ITridentRouter
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/retirement_v1/interfaces/ITridentRouter.sol)

Trident pool router interface.


## Functions
### exactInputSingleWithNativeToken


```solidity
function exactInputSingleWithNativeToken(ExactInputSingleParams calldata params)
    external
    payable
    returns (uint amountOut);
```

## Structs
### ExactInputSingleParams

```solidity
struct ExactInputSingleParams {
    uint amountIn;
    uint amountOutMinimum;
    address pool;
    address tokenIn;
    bytes data;
}
```

