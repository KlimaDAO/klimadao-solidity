# LibMeta
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/infinity/libraries/LibMeta.sol)


## State Variables
### EIP712_DOMAIN_TYPEHASH

```solidity
bytes32 internal constant EIP712_DOMAIN_TYPEHASH =
    keccak256(bytes("EIP712Domain(string name,string version,uint256 salt,address verifyingContract)"));
```


## Functions
### domainSeparator


```solidity
function domainSeparator(string memory name, string memory version) internal view returns (bytes32 domainSeparator_);
```

### getChainID


```solidity
function getChainID() internal view returns (uint id);
```

### msgSender


```solidity
function msgSender() internal view returns (address sender_);
```

