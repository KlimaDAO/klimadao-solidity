# ITridentRouter
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/704b462e69030cb9a43680057bee91d745d579ba/src/retirement_v1/interfaces/ITridentRouter.sol)

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

