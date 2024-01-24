# AltExercisepOLY
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/29fd912e7e35bfd36ad9c6e57c2a312d3aed3640/src/protocol/pKLIMA/AltExercisepKLIMA.sol)

Exercise contract for unapproved sellers prior to migrating pOLY.
It is not possible for a user to use both (no double dipping).


## State Variables
### owner

```solidity
address owner;
```


### newOwner

```solidity
address newOwner;
```


### pOLY

```solidity
address immutable pOLY;
```


### OHM

```solidity
address immutable OHM;
```


### DAI

```solidity
address immutable DAI;
```


### treasury

```solidity
address immutable treasury;
```


### circulatingOHMContract

```solidity
address immutable circulatingOHMContract;
```


### terms

```solidity
mapping(address => Term) public terms;
```


### walletChange

```solidity
mapping(address => address) public walletChange;
```


## Functions
### constructor


```solidity
constructor(address _pOLY, address _ohm, address _dai, address _treasury, address _circulatingOHMContract);
```

### setTerms


```solidity
function setTerms(address _vester, uint256 _rate, uint256 _claimed, uint256 _max) external;
```

### exercise


```solidity
function exercise(uint256 _amount) external;
```

### pushWalletChange


```solidity
function pushWalletChange(address _newWallet) external;
```

### pullWalletChange


```solidity
function pullWalletChange(address _oldWallet) external;
```

### redeemableFor


```solidity
function redeemableFor(address _vester) public view returns (uint256);
```

### redeemable


```solidity
function redeemable(Term memory _info) internal view returns (uint256);
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
    uint256 percent;
    uint256 claimed;
    uint256 max;
}
```

