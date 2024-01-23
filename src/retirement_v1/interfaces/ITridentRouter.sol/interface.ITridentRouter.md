# ITridentRouter
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/retirement_v1/interfaces/ITridentRouter.sol)

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

