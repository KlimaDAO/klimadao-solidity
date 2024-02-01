# Storage
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/infinity/AppStorage.sol)


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

### Token1155Settings
Stores the transient details of 1155 tokens received.


```solidity
struct Token1155Settings {
    uint256 tokenId;
    uint256 value;
    uint256[] ids;
    uint256[] values;
}
```

