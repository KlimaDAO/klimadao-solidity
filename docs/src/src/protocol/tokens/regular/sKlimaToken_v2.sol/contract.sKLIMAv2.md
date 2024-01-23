# sKLIMAv2
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/tokens/regular/sKlimaToken_v2.sol)

**Inherits:**
[ERC20Permit](/src/protocol/tokens/regular/KlimaToken.sol/abstract.ERC20Permit.md), [Ownable](/src/protocol/staking/regular/KlimaStaking_v2.sol/contract.Ownable.md)


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
uint public INDEX;
```


### MAX_UINT256

```solidity
uint private constant MAX_UINT256 = ~uint(0);
```


### INITIAL_FRAGMENTS_SUPPLY

```solidity
uint private constant INITIAL_FRAGMENTS_SUPPLY = 5_000_000 * 10 ** 9;
```


### TOTAL_GONS

```solidity
uint private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
```


### MAX_SUPPLY

```solidity
uint private constant MAX_SUPPLY = ~uint128(0);
```


### _gonsPerFragment

```solidity
uint private _gonsPerFragment;
```


### _gonBalances

```solidity
mapping(address => uint) private _gonBalances;
```


### _allowedValue

```solidity
mapping(address => mapping(address => uint)) private _allowedValue;
```


## Functions
### onlyStakingContract


```solidity
modifier onlyStakingContract();
```

### constructor


```solidity
constructor() ERC20("Staked Klima", "sKLIMA", 9) ERC20Permit;
```

### initialize


```solidity
function initialize(address stakingContract_) external returns (bool);
```

### setIndex


```solidity
function setIndex(uint _INDEX) external onlyManager returns (bool);
```

### rebase

increases sKLIMA supply to increase staking balances relative to profit_


```solidity
function rebase(uint profit_, uint epoch_) public onlyStakingContract returns (uint);
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
function _storeRebase(uint previousCirculating_, uint profit_, uint epoch_) internal returns (bool);
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
function balanceOf(address who) public view override returns (uint);
```

### gonsForBalance


```solidity
function gonsForBalance(uint amount) public view returns (uint);
```

### balanceForGons


```solidity
function balanceForGons(uint gons) public view returns (uint);
```

### circulatingSupply


```solidity
function circulatingSupply() public view returns (uint);
```

### index


```solidity
function index() public view returns (uint);
```

### transfer


```solidity
function transfer(address to, uint value) public override returns (bool);
```

### allowance


```solidity
function allowance(address owner_, address spender) public view override returns (uint);
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint value) public override returns (bool);
```

### approve


```solidity
function approve(address spender, uint value) public override returns (bool);
```

### _approve


```solidity
function _approve(address owner, address spender, uint value) internal virtual override;
```

### increaseAllowance


```solidity
function increaseAllowance(address spender, uint addedValue) public override returns (bool);
```

### decreaseAllowance


```solidity
function decreaseAllowance(address spender, uint subtractedValue) public override returns (bool);
```

## Events
### LogSupply

```solidity
event LogSupply(uint indexed epoch, uint timestamp, uint totalSupply);
```

### LogRebase

```solidity
event LogRebase(uint indexed epoch, uint rebase, uint index);
```

### LogStakingContractUpdated

```solidity
event LogStakingContractUpdated(address stakingContract);
```

## Structs
### Rebase

```solidity
struct Rebase {
    uint epoch;
    uint rebase;
    uint totalStakedBefore;
    uint totalStakedAfter;
    uint amountRebased;
    uint index;
    uint blockNumberOccured;
}
```

