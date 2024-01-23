# AppStorage
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/AppStorage.sol)


```solidity
struct AppStorage {
    mapping(uint => Storage.CarbonBridge) bridges;
    mapping(address => bool) isPoolToken;
    mapping(address => LibRetire.CarbonBridge) poolBridge;
    mapping(address => mapping(address => Storage.DefaultSwap)) swap;
    mapping(address => Account.State) a;
    uint lastERC721Received;
    uint fee;
    uint reentrantStatus;
    mapping(address => mapping(IERC20 => uint)) internalTokenBalance;
    mapping(address => uint) metaNonces;
    bytes32 domainSeparator;
    mapping(address => mapping(address => address)) tridentPool;
}
```

