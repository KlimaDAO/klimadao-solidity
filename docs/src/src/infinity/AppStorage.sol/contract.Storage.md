# Storage
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/704b462e69030cb9a43680057bee91d745d579ba/src/infinity/AppStorage.sol)


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

