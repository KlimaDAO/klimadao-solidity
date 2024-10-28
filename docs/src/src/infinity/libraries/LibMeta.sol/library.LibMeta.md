# LibMeta
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/infinity/libraries/LibMeta.sol)


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
function getChainID() internal view returns (uint256 id);
```

### msgSender


```solidity
function msgSender() internal view returns (address sender_);
```

### addressToString

*Converts an  address to a string representation.*


```solidity
function addressToString(address _address) internal pure returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|The address to convert.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|The string representation of the address.|


