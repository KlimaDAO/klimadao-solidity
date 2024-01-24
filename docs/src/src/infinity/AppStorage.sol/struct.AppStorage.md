# AppStorage
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/29fd912e7e35bfd36ad9c6e57c2a312d3aed3640/src/infinity/AppStorage.sol)


```solidity
struct AppStorage {
    mapping(uint256 => Storage.CarbonBridge) bridges;
    mapping(address => bool) isPoolToken;
    mapping(address => LibRetire.CarbonBridge) poolBridge;
    mapping(address => mapping(address => Storage.DefaultSwap)) swap;
    mapping(address => Account.State) a;
    uint256 lastERC721Received;
    uint256 fee;
    uint256 reentrantStatus;
    mapping(address => mapping(IERC20 => uint256)) internalTokenBalance;
    mapping(address => uint256) metaNonces;
    bytes32 domainSeparator;
    mapping(address => mapping(address => address)) tridentPool;
    Storage.Token1155Settings lastERC1155Received;
}
```

