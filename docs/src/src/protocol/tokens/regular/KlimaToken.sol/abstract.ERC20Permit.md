# ERC20Permit
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/tokens/regular/KlimaToken.sol)

**Inherits:**
[ERC20](/src/protocol/tokens/regular/KlimaToken.sol/abstract.ERC20.md), [IERC2612Permit](/src/protocol/tokens/regular/KlimaToken.sol/interface.IERC2612Permit.md)


## State Variables
### _nonces

```solidity
mapping(address => Counters.Counter) private _nonces;
```


### PERMIT_TYPEHASH

```solidity
bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
```


### DOMAIN_SEPARATOR

```solidity
bytes32 public DOMAIN_SEPARATOR;
```


## Functions
### constructor


```solidity
constructor();
```

### permit

*See {IERC2612Permit-permit}.*


```solidity
function permit(address owner, address spender, uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s)
    public
    virtual
    override;
```

### nonces

*See {IERC2612Permit-nonces}.*


```solidity
function nonces(address owner) public view override returns (uint);
```

