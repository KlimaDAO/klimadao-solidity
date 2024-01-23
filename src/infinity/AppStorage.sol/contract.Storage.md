# Storage
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/infinity/AppStorage.sol)


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

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|     The last tokenId received from transferSingle|
|`value`|`uint256`|       The last value received from transferSingle|
|`ids`|`uint256[]`|         The last tokenIds received from transferBatch|
|`values`|`uint256[]`|      The last values received from transferBatch|

