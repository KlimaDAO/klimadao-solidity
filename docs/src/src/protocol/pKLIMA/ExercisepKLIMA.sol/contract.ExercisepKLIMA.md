# ExercisepKLIMA
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/pKLIMA/ExercisepKLIMA.sol)


## State Variables
### owner

```solidity
address public owner;
```


### newOwner

```solidity
address public newOwner;
```


### pKLIMA

```solidity
address public immutable pKLIMA;
```


### KLIMA

```solidity
address public immutable KLIMA;
```


### BCT

```solidity
address public immutable BCT;
```


### treasury

```solidity
address public immutable treasury;
```


### circulatingKLIMAContract

```solidity
address public immutable circulatingKLIMAContract;
```


### terms

```solidity
mapping(address => Term) public terms;
```


### walletChange

```solidity
mapping(address => address) public walletChange;
```


### hasMigrated

```solidity
bool hasMigrated;
```


## Functions
### constructor


```solidity
constructor(address _pKLIMA, address _KLIMA, address _BCT, address _treasury, address _circulatingKLIMAContract);
```

### setTerms


```solidity
function setTerms(address _vester, uint _amountCanClaim, uint _rate) external returns (bool);
```

### exercise


```solidity
function exercise(uint _amount) external returns (bool);
```

### pushWalletChange


```solidity
function pushWalletChange(address _newWallet) external returns (bool);
```

### pullWalletChange


```solidity
function pullWalletChange(address _oldWallet) external returns (bool);
```

### redeemableFor


```solidity
function redeemableFor(address _vester) public view returns (uint);
```

### redeemable


```solidity
function redeemable(Term memory _info) internal view returns (uint);
```

### pushOwnership


```solidity
function pushOwnership(address _newOwner) external returns (bool);
```

### pullOwnership


```solidity
function pullOwnership() external returns (bool);
```

## Structs
### Term

```solidity
struct Term {
    uint percent;
    uint claimed;
    uint max;
}
```

