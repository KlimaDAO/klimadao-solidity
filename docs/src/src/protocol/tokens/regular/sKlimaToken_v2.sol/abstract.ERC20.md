# ERC20
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/protocol/tokens/regular/sKlimaToken_v2.sol)

**Inherits:**
[IERC20](/src/protocol/pKLIMA/ExercisepKLIMA.sol/interface.IERC20.md)


## State Variables
### ERC20TOKEN_ERC1820_INTERFACE_ID

```solidity
bytes32 private constant ERC20TOKEN_ERC1820_INTERFACE_ID = keccak256("ERC20Token");
```


### _balances

```solidity
mapping(address => uint256) internal _balances;
```


### _allowances

```solidity
mapping(address => mapping(address => uint256)) internal _allowances;
```


### _totalSupply

```solidity
uint256 internal _totalSupply;
```


### _name

```solidity
string internal _name;
```


### _symbol

```solidity
string internal _symbol;
```


### _decimals

```solidity
uint8 internal _decimals;
```


## Functions
### constructor

*Sets the values for [name](/src/protocol/tokens/regular/sKlimaToken_v2.sol/abstract.ERC20.md#name) and {symbol}, initializes {decimals} with
a default value of 18.
To select a different value for {decimals}, use {_setupDecimals}.
All three of these values are immutable: they can only be set once during
construction.*


```solidity
constructor(string memory name_, string memory symbol_, uint8 decimals_);
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
Ether and Wei. This is the value [ERC20](/src/protocol/tokens/regular/sKlimaToken_v2.sol/abstract.ERC20.md#erc20) uses, unless {_setupDecimals} is
called.
NOTE: This information is only used for _display_ purposes: it in
no way affects any of the arithmetic of the contract, including
{IERC20-balanceOf} and {IERC20-transfer}.*


```solidity
function decimals() public view returns (uint8);
```

### totalSupply

*See [IERC20-totalSupply](/src/protocol/tokens/upgradeable/KlimaIDONFT.sol/contract.KlimaIDONFT.md#totalsupply).*


```solidity
function totalSupply() public view override returns (uint256);
```

### balanceOf

*See [IERC20-balanceOf](/src/protocol/tokens/regular/sKlimaToken_v2.sol/contract.sKLIMAv2.md#balanceof).*


```solidity
function balanceOf(address account) public view virtual override returns (uint256);
```

### transfer

*See [IERC20-transfer](/src/protocol/tokens/regular/sKlimaToken_v2.sol/contract.sKLIMAv2.md#transfer).
Requirements:
- `recipient` cannot be the zero address.
- the caller must have a balance of at least `amount`.*


```solidity
function transfer(address recipient, uint256 amount) public virtual override returns (bool);
```

### allowance

*See [IERC20-allowance](/src/protocol/tokens/regular/sKlimaToken_v2.sol/contract.sKLIMAv2.md#allowance).*


```solidity
function allowance(address owner, address spender) public view virtual override returns (uint256);
```

### approve

*See [IERC20-approve](/src/protocol/tokens/regular/sKlimaToken_v2.sol/contract.sKLIMAv2.md#approve).
Requirements:
- `spender` cannot be the zero address.*


```solidity
function approve(address spender, uint256 amount) public virtual override returns (bool);
```

### transferFrom

*See [IERC20-transferFrom](/src/protocol/tokens/regular/sKlimaToken_v2.sol/contract.sKLIMAv2.md#transferfrom).
Emits an {Approval} event indicating the updated allowance. This is not
required by the EIP. See the note at the beginning of {ERC20}.
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
This is an alternative to [approve](/src/protocol/tokens/regular/sKlimaToken_v2.sol/abstract.ERC20.md#approve) that can be used as a mitigation for
problems described in {IERC20-approve}.
Emits an {Approval} event indicating the updated allowance.
Requirements:
- `spender` cannot be the zero address.*


```solidity
function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool);
```

### decreaseAllowance

*Atomically decreases the allowance granted to `spender` by the caller.
This is an alternative to [approve](/src/protocol/tokens/regular/sKlimaToken_v2.sol/abstract.ERC20.md#approve) that can be used as a mitigation for
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
This is internal function is equivalent to [transfer](/src/protocol/tokens/regular/sKlimaToken_v2.sol/abstract.ERC20.md#transfer), and can be used to
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
Requirements:
- `to` cannot be the zero address.*


```solidity
function _mint(address account_, uint256 ammount_) internal virtual;
```

### _burn

*Destroys `amount` tokens from `account`, reducing the
total supply.
Emits a {Transfer} event with `to` set to the zero address.
Requirements:
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

### _beforeTokenTransfer

*Sets [decimals](/src/protocol/tokens/regular/sKlimaToken_v2.sol/abstract.ERC20.md#decimals) to a value other than the default one of 18.
WARNING: This function should only be called from the constructor. Most
applications that interact with token contracts will not expect
{decimals} to ever change, and may work incorrectly if it does.*

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
function _beforeTokenTransfer(address from_, address to_, uint256 amount_) internal virtual;
```

