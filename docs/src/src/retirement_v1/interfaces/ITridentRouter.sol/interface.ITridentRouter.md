# ITridentRouter
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/retirement_v1/interfaces/ITridentRouter.sol)

Trident pool router interface.


## Functions
### exactInputSingleWithNativeToken


```solidity
function exactInputSingleWithNativeToken(ExactInputSingleParams calldata params)
    external
    payable
    returns (uint256 amountOut);
```

## Structs
### ExactInputSingleParams

```solidity
struct ExactInputSingleParams {
    uint256 amountIn;
    uint256 amountOutMinimum;
    address pool;
    address tokenIn;
    bytes data;
}
```

