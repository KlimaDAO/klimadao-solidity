# MetaTransactionsFacet
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/infinity/facets/MetaTransactionsFacet.sol)

**Inherits:**
[ReentrancyGuard](/src/infinity/ReentrancyGuard.sol/abstract.ReentrancyGuard.md)


## State Variables
### META_TRANSACTION_TYPEHASH

```solidity
bytes32 private constant META_TRANSACTION_TYPEHASH =
    keccak256(bytes("MetaTransaction(uint256 nonce,address from,bytes functionSignature)"));
```


## Functions
### convertBytesToBytes4


```solidity
function convertBytesToBytes4(bytes memory inBytes) internal pure returns (bytes4 outBytes4);
```

### getDomainSeparator


```solidity
function getDomainSeparator() private view returns (bytes32);
```

### toTypedMessageHash

Accept message hash and returns hash message in EIP712 compatible form
So that it can be used to recover signer from signature signed using EIP712 formatted data
https://eips.ethereum.org/EIPS/eip-712
"\\x19" makes the encoding deterministic
"\\x01" is the version byte to make it compatible to EIP-191


```solidity
function toTypedMessageHash(bytes32 messageHash) internal view returns (bytes32);
```

### hashMetaTransaction


```solidity
function hashMetaTransaction(MetaTransaction memory metaTx) internal pure returns (bytes32);
```

### getNonce

Query the latest nonce of an address


```solidity
function getNonce(address user) external view returns (uint256 nonce_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|Address to query|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`nonce_`|`uint256`|The latest nonce for the address|


### verify


```solidity
function verify(address user, MetaTransaction memory metaTx, bytes32 sigR, bytes32 sigS, uint8 sigV)
    internal
    view
    returns (bool);
```

### executeMetaTransaction


```solidity
function executeMetaTransaction(
    address userAddress,
    bytes memory functionSignature,
    bytes32 sigR,
    bytes32 sigS,
    uint8 sigV
) public payable returns (bytes memory);
```

## Events
### MetaTransactionExecuted

```solidity
event MetaTransactionExecuted(address userAddress, address payable relayerAddress, bytes functionSignature);
```

## Structs
### MetaTransaction

```solidity
struct MetaTransaction {
    uint256 nonce;
    address from;
    bytes functionSignature;
}
```

