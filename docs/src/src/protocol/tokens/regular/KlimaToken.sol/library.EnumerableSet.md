# EnumerableSet
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/29fd912e7e35bfd36ad9c6e57c2a312d3aed3640/src/protocol/tokens/regular/KlimaToken.sol)


## Functions
### _add

*Add a value to a set. O(1).
Returns true if the value was added to the set, that is if it was not
already present.*


```solidity
function _add(Set storage set, bytes32 value) private returns (bool);
```

### _remove

*Removes a value from a set. O(1).
Returns true if the value was removed from the set, that is if it was
present.*


```solidity
function _remove(Set storage set, bytes32 value) private returns (bool);
```

### _contains

*Returns true if the value is in the set. O(1).*


```solidity
function _contains(Set storage set, bytes32 value) private view returns (bool);
```

### _length

*Returns the number of values on the set. O(1).*


```solidity
function _length(Set storage set) private view returns (uint256);
```

### _at

*Returns the value stored at position `index` in the set. O(1).
Note that there are no guarantees on the ordering of values inside the
array, and it may change when more values are added or removed.
Requirements:
- `index` must be strictly less than {length}.*


```solidity
function _at(Set storage set, uint256 index) private view returns (bytes32);
```

### _getValues


```solidity
function _getValues(Set storage set_) private view returns (bytes32[] storage);
```

### _insert

Inserts new value by moving existing value at provided index to end of array and setting provided value at provided index


```solidity
function _insert(Set storage set_, uint256 index_, bytes32 valueToInsert_) private returns (bool);
```

### add

*Add a value to a set. O(1).
Returns true if the value was added to the set, that is if it was not
already present.*


```solidity
function add(Bytes4Set storage set, bytes4 value) internal returns (bool);
```

### remove

*Removes a value from a set. O(1).
Returns true if the value was removed from the set, that is if it was
present.*


```solidity
function remove(Bytes4Set storage set, bytes4 value) internal returns (bool);
```

### contains

*Returns true if the value is in the set. O(1).*


```solidity
function contains(Bytes4Set storage set, bytes4 value) internal view returns (bool);
```

### length

*Returns the number of values on the set. O(1).*


```solidity
function length(Bytes4Set storage set) internal view returns (uint256);
```

### at

*Returns the value stored at position `index` in the set. O(1).
Note that there are no guarantees on the ordering of values inside the
array, and it may change when more values are added or removed.
Requirements:
- `index` must be strictly less than {length}.*


```solidity
function at(Bytes4Set storage set, uint256 index) internal view returns (bytes4);
```

### getValues


```solidity
function getValues(Bytes4Set storage set_) internal view returns (bytes4[] memory);
```

### insert


```solidity
function insert(Bytes4Set storage set_, uint256 index_, bytes4 valueToInsert_) internal returns (bool);
```

### add

*Add a value to a set. O(1).
Returns true if the value was added to the set, that is if it was not
already present.*


```solidity
function add(Bytes32Set storage set, bytes32 value) internal returns (bool);
```

### remove

*Removes a value from a set. O(1).
Returns true if the value was removed from the set, that is if it was
present.*


```solidity
function remove(Bytes32Set storage set, bytes32 value) internal returns (bool);
```

### contains

*Returns true if the value is in the set. O(1).*


```solidity
function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool);
```

### length

*Returns the number of values on the set. O(1).*


```solidity
function length(Bytes32Set storage set) internal view returns (uint256);
```

### at

*Returns the value stored at position `index` in the set. O(1).
Note that there are no guarantees on the ordering of values inside the
array, and it may change when more values are added or removed.
Requirements:
- `index` must be strictly less than {length}.*


```solidity
function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32);
```

### getValues


```solidity
function getValues(Bytes32Set storage set_) internal view returns (bytes4[] memory);
```

### insert


```solidity
function insert(Bytes32Set storage set_, uint256 index_, bytes32 valueToInsert_) internal returns (bool);
```

### add

*Add a value to a set. O(1).
Returns true if the value was added to the set, that is if it was not
already present.*


```solidity
function add(AddressSet storage set, address value) internal returns (bool);
```

### remove

*Removes a value from a set. O(1).
Returns true if the value was removed from the set, that is if it was
present.*


```solidity
function remove(AddressSet storage set, address value) internal returns (bool);
```

### contains

*Returns true if the value is in the set. O(1).*


```solidity
function contains(AddressSet storage set, address value) internal view returns (bool);
```

### length

*Returns the number of values in the set. O(1).*


```solidity
function length(AddressSet storage set) internal view returns (uint256);
```

### at

*Returns the value stored at position `index` in the set. O(1).
Note that there are no guarantees on the ordering of values inside the
array, and it may change when more values are added or removed.
Requirements:
- `index` must be strictly less than {length}.*


```solidity
function at(AddressSet storage set, uint256 index) internal view returns (address);
```

### getValues

TODO Might require explicit conversion of bytes32[] to address[].
Might require iteration.


```solidity
function getValues(AddressSet storage set_) internal view returns (address[] memory);
```

### insert


```solidity
function insert(AddressSet storage set_, uint256 index_, address valueToInsert_) internal returns (bool);
```

### add

*Add a value to a set. O(1).
Returns true if the value was added to the set, that is if it was not
already present.*


```solidity
function add(UintSet storage set, uint256 value) internal returns (bool);
```

### remove

*Removes a value from a set. O(1).
Returns true if the value was removed from the set, that is if it was
present.*


```solidity
function remove(UintSet storage set, uint256 value) internal returns (bool);
```

### contains

*Returns true if the value is in the set. O(1).*


```solidity
function contains(UintSet storage set, uint256 value) internal view returns (bool);
```

### length

*Returns the number of values on the set. O(1).*


```solidity
function length(UintSet storage set) internal view returns (uint256);
```

### at

*Returns the value stored at position `index` in the set. O(1).
Note that there are no guarantees on the ordering of values inside the
array, and it may change when more values are added or removed.
Requirements:
- `index` must be strictly less than {length}.*


```solidity
function at(UintSet storage set, uint256 index) internal view returns (uint256);
```

### add

*Add a value to a set. O(1).
Returns true if the value was added to the set, that is if it was not
already present.*


```solidity
function add(UInt256Set storage set, uint256 value) internal returns (bool);
```

### remove

*Removes a value from a set. O(1).
Returns true if the value was removed from the set, that is if it was
present.*


```solidity
function remove(UInt256Set storage set, uint256 value) internal returns (bool);
```

### contains

*Returns true if the value is in the set. O(1).*


```solidity
function contains(UInt256Set storage set, uint256 value) internal view returns (bool);
```

### length

*Returns the number of values on the set. O(1).*


```solidity
function length(UInt256Set storage set) internal view returns (uint256);
```

### at

*Returns the value stored at position `index` in the set. O(1).
Note that there are no guarantees on the ordering of values inside the
array, and it may change when more values are added or removed.
Requirements:
- `index` must be strictly less than {length}.*


```solidity
function at(UInt256Set storage set, uint256 index) internal view returns (uint256);
```

## Structs
### Set

```solidity
struct Set {
    bytes32[] _values;
    mapping(bytes32 => uint256) _indexes;
}
```

### Bytes4Set

```solidity
struct Bytes4Set {
    Set _inner;
}
```

### Bytes32Set

```solidity
struct Bytes32Set {
    Set _inner;
}
```

### AddressSet

```solidity
struct AddressSet {
    Set _inner;
}
```

### UintSet

```solidity
struct UintSet {
    Set _inner;
}
```

### UInt256Set

```solidity
struct UInt256Set {
    Set _inner;
}
```

