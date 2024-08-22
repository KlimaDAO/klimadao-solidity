# Counters
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b4fb0f4685d5fe4c80ffc162389dfe0abdfe9f39/src/protocol/tokens/regular/sKlimaToken.sol)


## Functions
### current


```solidity
function current(Counter storage counter) internal view returns (uint256);
```

### increment


```solidity
function increment(Counter storage counter) internal;
```

### decrement


```solidity
function decrement(Counter storage counter) internal;
```

## Structs
### Counter

```solidity
struct Counter {
    uint256 _value;
}
```

