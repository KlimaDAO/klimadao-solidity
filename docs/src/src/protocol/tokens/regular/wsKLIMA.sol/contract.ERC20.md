# ERC20
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/protocol/tokens/regular/wsKLIMA.sol)

**Inherits:**
[IERC20](/src/protocol/pKLIMA/ExercisepKLIMA.sol/interface.IERC20.md)

*Implementation of the {IERC20} interface.
This implementation is agnostic to the way tokens are created. This means
that a supply mechanism has to be added in a derived contract using {_mint}.
For a generic mechanism see {ERC20PresetMinterPauser}.
TIP: For a detailed writeup see our guide
https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
to implement supply mechanisms].
We have followed general OpenZeppelin guidelines: functions revert instead
of returning `false` on failure. This behavior is nonetheless conventional
and does not conflict with the expectations of ERC20 applications.
Additionally, an {Approval} event is emitted on calls to {transferFrom}.
This allows applications to reconstruct the allowance for all accounts just
by listening to said events. Other implementations of the EIP may not emit
these events, as it isn't required by the specification.
Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
functions have been added to mitigate the well-known issues around setting
allowances. See {IERC20-approve}.*


## State Variables
### _balances

```solidity
mapping(address => uint256) private _balances;
```


### _allowances

```solidity
mapping(address => mapping(address => uint256)) private _allowances;
```


### _totalSupply

```solidity
uint256 private _totalSupply;
```


### _name

```solidity
string private _name;
```


### _symbol

```solidity
string private _symbol;
```


### _decimals

```solidity
uint8 private _decimals;
```


## Functions
### constructor

*Sets the values for [name](/src/protocol/tokens/regular/wsKLIMA.sol/contract.ERC20.md#name) and {symbol}, initializes {decimals} with
a default value of 18.
To select a different value for {decimals}, use {_setupDecimals}.
All three of these values are immutable: they can only be set once during
construction.*


```solidity
constructor(string memory name, string memory symbol);
```

### name

*Returns the name of the token.*


```solidity
function name() public view returns (string memory);
```

### symbol

*Returns the symbol of the token, usually a shorter version of the
name.*


```solidity
function symbol() public view returns (string memory);
```

### decimals

*Returns the number of decimals used to get its user representation.
For example, if `decimals` equals `2`, a balance of `505` tokens should
be displayed to a user as `5,05` (`505 / 10 ** 2`).
Tokens usually opt for a value of 18, imitating the relationship between
Ether and Wei. This is the value [ERC20](/src/protocol/tokens/regular/wsKLIMA.sol/contract.ERC20.md#erc20) uses, unless {_setupDecimals} is
called.
NOTE: This information is only used for _display_ purposes: it in
no way affects any of the arithmetic of the contract, including
{IERC20-balanceOf} and {IERC20-transfer}.*


```solidity
function decimals() public view returns (uint8);
```

### totalSupply

*See [IERC20-totalSupply](/src/protocol/tokens/regular/sKlimaToken.sol/interface.IERC20.md#totalsupply).*


```solidity
function totalSupply() public view override returns (uint256);
```

### balanceOf

*See [IERC20-balanceOf](/src/protocol/tokens/regular/sKlimaToken.sol/interface.IERC20.md#balanceof).*


```solidity
function balanceOf(address account) public view override returns (uint256);
```

### transfer

*See [IERC20-transfer](/src/protocol/tokens/regular/sKlimaToken.sol/interface.IERC20.md#transfer).
Requirements:
- `recipient` cannot be the zero address.
- the caller must have a balance of at least `amount`.*


```solidity
function transfer(address recipient, uint256 amount) public virtual override returns (bool);
```

### allowance

*See [IERC20-allowance](/src/protocol/tokens/regular/sKlimaToken.sol/interface.IERC20.md#allowance).*


```solidity
function allowance(address owner, address spender) public view virtual override returns (uint256);
```

### approve

*See [IERC20-approve](/src/protocol/tokens/regular/sKlimaToken.sol/interface.IERC20.md#approve).
Requirements:
- `spender` cannot be the zero address.*


```solidity
function approve(address spender, uint256 amount) public virtual override returns (bool);
```

### transferFrom

*See [IERC20-transferFrom](/src/protocol/tokens/regular/sKlimaToken.sol/interface.IERC20.md#transferfrom).
Emits an {Approval} event indicating the updated allowance. This is not
required by the EIP. See the note at the beginning of {ERC20};
Requirements:
- `sender` and `recipient` cannot be the zero address.
- `sender` must have a balance of at least `amount`.
- the caller must have allowance for ``sender``'s tokens of at least
`amount`.*


```solidity
function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool);
```

### increaseAllowance

*Atomically increases the allowance granted to `spender` by the caller.
This is an alternative to [approve](/src/protocol/tokens/regular/wsKLIMA.sol/contract.ERC20.md#approve) that can be used as a mitigation for
problems described in {IERC20-approve}.
Emits an {Approval} event indicating the updated allowance.
Requirements:
- `spender` cannot be the zero address.*


```solidity
function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool);
```

### decreaseAllowance

*Atomically decreases the allowance granted to `spender` by the caller.
This is an alternative to [approve](/src/protocol/tokens/regular/wsKLIMA.sol/contract.ERC20.md#approve) that can be used as a mitigation for
problems described in {IERC20-approve}.
Emits an {Approval} event indicating the updated allowance.
Requirements:
- `spender` cannot be the zero address.
- `spender` must have allowance for the caller of at least
`subtractedValue`.*


```solidity
function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool);
```

### _transfer

*Moves tokens `amount` from `sender` to `recipient`.
This is internal function is equivalent to [transfer](/src/protocol/tokens/regular/wsKLIMA.sol/contract.ERC20.md#transfer), and can be used to
e.g. implement automatic token fees, slashing mechanisms, etc.
Emits a {Transfer} event.
Requirements:
- `sender` cannot be the zero address.
- `recipient` cannot be the zero address.
- `sender` must have a balance of at least `amount`.*


```solidity
function _transfer(address sender, address recipient, uint256 amount) internal virtual;
```

### _mint

*Creates `amount` tokens and assigns them to `account`, increasing
the total supply.
Emits a {Transfer} event with `from` set to the zero address.
Requirements
- `to` cannot be the zero address.*


```solidity
function _mint(address account, uint256 amount) internal virtual;
```

### _burn

*Destroys `amount` tokens from `account`, reducing the
total supply.
Emits a {Transfer} event with `to` set to the zero address.
Requirements
- `account` cannot be the zero address.
- `account` must have at least `amount` tokens.*


```solidity
function _burn(address account, uint256 amount) internal virtual;
```

### _approve

*Sets `amount` as the allowance of `spender` over the `owner` s tokens.
This internal function is equivalent to `approve`, and can be used to
e.g. set automatic allowances for certain subsystems, etc.
Emits an {Approval} event.
Requirements:
- `owner` cannot be the zero address.
- `spender` cannot be the zero address.*


```solidity
function _approve(address owner, address spender, uint256 amount) internal virtual;
```

### _setupDecimals

*Sets [decimals](/src/protocol/tokens/regular/wsKLIMA.sol/contract.ERC20.md#decimals) to a value other than the default one of 18.
WARNING: This function should only be called from the constructor. Most
applications that interact with token contracts will not expect
{decimals} to ever change, and may work incorrectly if it does.*


```solidity
function _setupDecimals(uint8 decimals_) internal;
```

### _beforeTokenTransfer

*Hook that is called before any transfer of tokens. This includes
minting and burning.
Calling conditions:
- when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
will be to transferred to `to`.
- when `from` is zero, `amount` tokens will be minted for `to`.
- when `to` is zero, `amount` of ``from``'s tokens will be burned.
- `from` and `to` are never both zero.
To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].*


```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual;
```

