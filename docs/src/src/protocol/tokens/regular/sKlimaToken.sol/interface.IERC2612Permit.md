# IERC2612Permit
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/0daf6561853dcea28093c3f0ddf1098de21c5de2/src/protocol/tokens/regular/sKlimaToken.sol)


## Functions
### permit

*Sets `amount` as the allowance of `spender` over `owner`'s tokens,
given `owner`'s signed approval.
IMPORTANT: The same issues [IERC20-approve](/src/protocol/tokens/regular/sKlimaToken.sol/contract.sKlima.md#approve) has related to transaction
ordering also apply here.
Emits an {Approval} event.
Requirements:
- `owner` cannot be the zero address.
- `spender` cannot be the zero address.
- `deadline` must be a timestamp in the future.
- `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
over the EIP712-formatted function arguments.
- the signature must use ``owner``'s current nonce (see {nonces}).
For more information on the signature format, see the
https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
section].*


```solidity
function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
    external;
```

### nonces

*Returns the current ERC2612 nonce for `owner`. This value must be
included whenever a signature is generated for [permit](/src/protocol/tokens/regular/sKlimaToken.sol/interface.IERC2612Permit.md#permit).
Every successful call to {permit} increases ``owner``'s nonce by one. This
prevents a signature from being used multiple times.*


```solidity
function nonces(address owner) external view returns (uint256);
```

