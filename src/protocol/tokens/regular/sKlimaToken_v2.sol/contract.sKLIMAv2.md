# sKLIMAv2
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/d2235caa445c673ffcb1a4a1d8c97c8c3cba5198/src/protocol/tokens/regular/sKlimaToken_v2.sol)

**Inherits:**
[ERC20Permit](/src/protocol/tokens/regular/sKlimaToken.sol/abstract.ERC20Permit.md), [Ownable](/src/integrations/sushixklima/Ownable.sol/contract.Ownable.md)


## State Variables
### stakingContract

```solidity
address public stakingContract;
```


### initializer

```solidity
address public initializer;
```


### rebases

```solidity
Rebase[] public rebases;
```


### INDEX

```solidity
uint256 public INDEX;
```


### MAX_UINT256

```solidity
uint256 private constant MAX_UINT256 = ~uint256(0);
```


### INITIAL_FRAGMENTS_SUPPLY

```solidity
uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 5_000_000 * 10 ** 9;
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


### _allowedValue

```solidity
mapping(address => mapping(address => uint256)) private _allowedValue;
```


## Functions
### onlyStakingContract


```solidity
modifier onlyStakingContract();
```

### constructor


```solidity
constructor() ERC20("Staked Klima", "sKLIMA", 9) ERC20Permit();
```

### initialize


```solidity
function initialize(address stakingContract_) external returns (bool);
```

### setIndex


```solidity
function setIndex(uint256 _INDEX) external onlyManager returns (bool);
```

### rebase

increases sKLIMA supply to increase staking balances relative to profit_


```solidity
function rebase(uint256 profit_, uint256 epoch_) public onlyStakingContract returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`profit_`|`uint256`|uint256|
|`epoch_`|`uint256`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|uint256|


### _storeRebase

emits event with data about rebase


```solidity
function _storeRebase(uint256 previousCirculating_, uint256 profit_, uint256 epoch_) internal returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`previousCirculating_`|`uint256`|uint|
|`profit_`|`uint256`|uint|
|`epoch_`|`uint256`|uint|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool|


### balanceOf


```solidity
function balanceOf(address who) public view override returns (uint256);
```

### gonsForBalance


```solidity
function gonsForBalance(uint256 amount) public view returns (uint256);
```

### balanceForGons


```solidity
function balanceForGons(uint256 gons) public view returns (uint256);
```

### circulatingSupply


```solidity
function circulatingSupply() public view returns (uint256);
```

### index


```solidity
function index() public view returns (uint256);
```

### transfer


```solidity
function transfer(address to, uint256 value) public override returns (bool);
```

### allowance


```solidity
function allowance(address owner_, address spender) public view override returns (uint256);
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint256 value) public override returns (bool);
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
### LogSupply

```solidity
event LogSupply(uint256 indexed epoch, uint256 timestamp, uint256 totalSupply);
```

### LogRebase

```solidity
event LogRebase(uint256 indexed epoch, uint256 rebase, uint256 index);
```

### LogStakingContractUpdated

```solidity
event LogStakingContractUpdated(address stakingContract);
```

## Structs
### Rebase

```solidity
struct Rebase {
    uint256 epoch;
    uint256 rebase;
    uint256 totalStakedBefore;
    uint256 totalStakedAfter;
    uint256 amountRebased;
    uint256 index;
    uint256 blockNumberOccured;
}
```

