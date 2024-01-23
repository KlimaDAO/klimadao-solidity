# Storage
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/AppStorage.sol)


## Structs
### CarbonBridge

```solidity
struct CarbonBridge {
    string name;
    address defaultRouter;
    uint8 routerType;
}
```

### DefaultSwap

```solidity
struct DefaultSwap {
    uint8[] swapDexes;
    address[] ammRouters;
    mapping(uint8 => address[]) swapPaths;
}
```

