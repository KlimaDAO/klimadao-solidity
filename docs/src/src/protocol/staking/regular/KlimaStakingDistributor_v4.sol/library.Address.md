# Address
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/protocol/staking/regular/KlimaStakingDistributor_v4.sol)


## Functions
### isContract


```solidity
function isContract(address account) internal view returns (bool);
```

### sendValue


```solidity
function sendValue(address payable recipient, uint256 amount) internal;
```

### functionCall


```solidity
function functionCall(address target, bytes memory data) internal returns (bytes memory);
```

### functionCall


```solidity
function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory);
```

### functionCallWithValue


```solidity
function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory);
```

### functionCallWithValue


```solidity
function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage)
    internal
    returns (bytes memory);
```

### _functionCallWithValue


```solidity
function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage)
    private
    returns (bytes memory);
```

### functionStaticCall


```solidity
function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory);
```

### functionStaticCall


```solidity
function functionStaticCall(address target, bytes memory data, string memory errorMessage)
    internal
    view
    returns (bytes memory);
```

### functionDelegateCall


```solidity
function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory);
```

### functionDelegateCall


```solidity
function functionDelegateCall(address target, bytes memory data, string memory errorMessage)
    internal
    returns (bytes memory);
```

### _verifyCallResult


```solidity
function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage)
    private
    pure
    returns (bytes memory);
```

### addressToString


```solidity
function addressToString(address _address) internal pure returns (string memory);
```

