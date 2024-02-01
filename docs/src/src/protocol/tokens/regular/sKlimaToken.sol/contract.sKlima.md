# sKlima
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/704b462e69030cb9a43680057bee91d745d579ba/src/protocol/tokens/regular/sKlimaToken.sol)

**Inherits:**
[ERC20Permit](/src/protocol/tokens/regular/KlimaToken.sol/abstract.ERC20Permit.md), [Ownable](/src/protocol/staking/regular/KlimaStaking_v2.sol/contract.Ownable.md)


## State Variables
### monetaryPolicy

```solidity
address public monetaryPolicy;
```


### stakingContract

```solidity
address public stakingContract;
```


### MAX_UINT256

```solidity
uint256 private constant MAX_UINT256 = ~uint256(0);
```


### INITIAL_FRAGMENTS_SUPPLY

```solidity
uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 500_000 * 10 ** 9;
```


### TOTAL_GONS

```solidity
uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
```


### MAX_SUPPLY

```solidity
uint256 private constant MAX_SUPPLY = ~uint128(0);
```


### _gonsPerFragment

```solidity
uint256 private _gonsPerFragment;
```


### _gonBalances

```solidity
mapping(address => uint256) private _gonBalances;
```


### _allowedFragments

```solidity
mapping(address => mapping(address => uint256)) private _allowedFragments;
```


## Functions
### onlyMonetaryPolicy


```solidity
modifier onlyMonetaryPolicy();
```

### validRecipient


```solidity
modifier validRecipient(address to);
```

### constructor


```solidity
constructor() ERC20("Staked Klima", "sKLIMA", 9);
```

### setStakingContract


```solidity
function setStakingContract(address newStakingContract_) external onlyOwner;
```

### setMonetaryPolicy


```solidity
function setMonetaryPolicy(address monetaryPolicy_) external onlyOwner;
```

### rebase


```solidity
function rebase(uint256 olyProfit) public onlyMonetaryPolicy returns (uint256);
```

### balanceOf


```solidity
function balanceOf(address who) public view override returns (uint256);
```

### circulatingSupply


```solidity
function circulatingSupply() public view returns (uint256);
```

### transfer


```solidity
function transfer(address to, uint256 value) public override validRecipient(to) returns (bool);
```

### allowance


```solidity
function allowance(address owner_, address spender) public view override returns (uint256);
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint256 value) public override validRecipient(to) returns (bool);
```

### approve


```solidity
function approve(address spender, uint256 value) public override returns (bool);
```

### _approve


```solidity
function _approve(address owner, address spender, uint256 value) internal virtual override;
```

### increaseAllowance


```solidity
function increaseAllowance(address spender, uint256 addedValue) public override returns (bool);
```

### decreaseAllowance


```solidity
function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool);
```

## Events
### LogRebase

```solidity
event LogRebase(uint256 indexed epoch, uint256 totalSupply);
```

### LogMonetaryPolicyUpdated

```solidity
event LogMonetaryPolicyUpdated(address monetaryPolicy);
```

