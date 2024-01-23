# SafeMath
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/b98fc1e8b7dcf2a7b80bbaba384c8c84431739fc/src/protocol/pKLIMA/AltExercisepKLIMA.sol)

*Wrappers over Solidity's arithmetic operations with added overflow
checks.
Arithmetic operations in Solidity wrap on overflow. This can easily result
in bugs, because programmers usually assume that an overflow raises an
error, which is the standard behavior in high level programming languages.
`SafeMath` restores this intuition by reverting the transaction when an
operation overflows.
Using this library instead of the unchecked operations eliminates an entire
class of bugs, so it's recommended to use it always.*


## Functions
### add

*Returns the addition of two unsigned integers, reverting on
overflow.
Counterpart to Solidity's `+` operator.
Requirements:
- Addition cannot overflow.*


```solidity
function add(uint a, uint b) internal pure returns (uint);
```

### sub

*Returns the subtraction of two unsigned integers, reverting on
overflow (when the result is negative).
Counterpart to Solidity's `-` operator.
Requirements:
- Subtraction cannot overflow.*


```solidity
function sub(uint a, uint b) internal pure returns (uint);
```

### sub

*Returns the subtraction of two unsigned integers, reverting with custom message on
overflow (when the result is negative).
Counterpart to Solidity's `-` operator.
Requirements:
- Subtraction cannot overflow.*


```solidity
function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint);
```

### mul

*Returns the multiplication of two unsigned integers, reverting on
overflow.
Counterpart to Solidity's `*` operator.
Requirements:
- Multiplication cannot overflow.*


```solidity
function mul(uint a, uint b) internal pure returns (uint);
```

### div

*Returns the integer division of two unsigned integers. Reverts on
division by zero. The result is rounded towards zero.
Counterpart to Solidity's `/` operator. Note: this function uses a
`revert` opcode (which leaves remaining gas untouched) while Solidity
uses an invalid opcode to revert (consuming all remaining gas).
Requirements:
- The divisor cannot be zero.*


```solidity
function div(uint a, uint b) internal pure returns (uint);
```

### div

*Returns the integer division of two unsigned integers. Reverts with custom message on
division by zero. The result is rounded towards zero.
Counterpart to Solidity's `/` operator. Note: this function uses a
`revert` opcode (which leaves remaining gas untouched) while Solidity
uses an invalid opcode to revert (consuming all remaining gas).
Requirements:
- The divisor cannot be zero.*


```solidity
function div(uint a, uint b, string memory errorMessage) internal pure returns (uint);
```

### mod

*Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
Reverts when dividing by zero.
Counterpart to Solidity's `%` operator. This function uses a `revert`
opcode (which leaves remaining gas untouched) while Solidity uses an
invalid opcode to revert (consuming all remaining gas).
Requirements:
- The divisor cannot be zero.*


```solidity
function mod(uint a, uint b) internal pure returns (uint);
```

### mod

*Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
Reverts with custom message when dividing by zero.
Counterpart to Solidity's `%` operator. This function uses a `revert`
opcode (which leaves remaining gas untouched) while Solidity uses an
invalid opcode to revert (consuming all remaining gas).
Requirements:
- The divisor cannot be zero.*


```solidity
function mod(uint a, uint b, string memory errorMessage) internal pure returns (uint);
```

### sqrrt


```solidity
function sqrrt(uint a) internal pure returns (uint c);
```

### percentageAmount


```solidity
function percentageAmount(uint total_, uint8 percentage_) internal pure returns (uint percentAmount_);
```

### substractPercentage


```solidity
function substractPercentage(uint total_, uint8 percentageToSub_) internal pure returns (uint result_);
```

### percentageOfTotal


```solidity
function percentageOfTotal(uint part_, uint total_) internal pure returns (uint percent_);
```

### average

Taken from Hypersonic https://github.com/M2629/HyperSonic/blob/main/Math.sol

*Returns the average of two numbers. The result is rounded towards
zero.*


```solidity
function average(uint a, uint b) internal pure returns (uint);
```

### quadraticPricing


```solidity
function quadraticPricing(uint payment_, uint multiplier_) internal pure returns (uint);
```

### bondingCurve


```solidity
function bondingCurve(uint supply_, uint multiplier_) internal pure returns (uint);
```

