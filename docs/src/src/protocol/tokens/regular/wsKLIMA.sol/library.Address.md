# Address
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/protocol/tokens/regular/wsKLIMA.sol)

*Collection of functions related to the address type*


## Functions
### isContract

*Returns true if `account` is a contract.
[IMPORTANT]
====
It is unsafe to assume that an address for which this function returns
false is an externally-owned account (EOA) and not a contract.
Among others, `isContract` will return false for the following
types of addresses:
- an externally-owned account
- a contract in construction
- an address where a contract will be created
- an address where a contract lived, but was destroyed
====*


```solidity
function isContract(address account) internal view returns (bool);
```

### sendValue

*Replacement for Solidity's `transfer`: sends `amount` wei to
`recipient`, forwarding all available gas and reverting on errors.
https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
of certain opcodes, possibly making contracts go over the 2300 gas limit
imposed by `transfer`, making them unable to receive funds via
`transfer`. [sendValue](/src/protocol/tokens/regular/wsKLIMA.sol/library.Address.md#sendvalue) removes this limitation.
https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
IMPORTANT: because control is transferred to `recipient`, care must be
taken to not create reentrancy vulnerabilities. Consider using
{ReentrancyGuard} or the
https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].*


```solidity
function sendValue(address payable recipient, uint256 amount) internal;
```

### functionCall

*Performs a Solidity function call using a low level `call`. A
plain`call` is an unsafe replacement for a function call: use this
function instead.
If `target` reverts with a revert reason, it is bubbled up by this
function (like regular Solidity function calls).
Returns the raw returned data. To convert to the expected return value,
use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
Requirements:
- `target` must be a contract.
- calling `target` with `data` must not revert.
_Available since v3.1._*


```solidity
function functionCall(address target, bytes memory data) internal returns (bytes memory);
```

### functionCall

*Same as [`functionCall`](/src/protocol/tokens/regular/sKlimaToken.sol/library.Address.md#functioncall), but with
`errorMessage` as a fallback revert reason when `target` reverts.
_Available since v3.1._*


```solidity
function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory);
```

### functionCallWithValue

*Same as [`functionCall`](/src/protocol/tokens/regular/sKlimaToken.sol/library.Address.md#functioncall),
but also transferring `value` wei to `target`.
Requirements:
- the calling contract must have an ETH balance of at least `value`.
- the called Solidity function must be `payable`.
_Available since v3.1._*


```solidity
function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory);
```

### functionCallWithValue

*Same as [`functionCallWithValue`](/src/protocol/tokens/regular/sKlimaToken.sol/library.Address.md#functioncallwithvalue), but
with `errorMessage` as a fallback revert reason when `target` reverts.
_Available since v3.1._*


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

