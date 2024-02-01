# SafeMath
[Git Source](https://github.com/KlimaDAO/klimadao-solidity/blob/36109e4551048e978d232da5905a9cf6eaf3e3e2/src/protocol/staking/regular/KlimaStaking_v2.sol)

Submitted for verification at Etherscan.io on 2021-06-12


## Functions
### add

*Returns the addition of two unsigned integers, reverting on
overflow.
Counterpart to Solidity's `+` operator.
Requirements:
- Addition cannot overflow.*


```solidity
function add(uint256 a, uint256 b) internal pure returns (uint256);
```

### sub

*Returns the subtraction of two unsigned integers, reverting on
overflow (when the result is negative).
Counterpart to Solidity's `-` operator.
Requirements:
- Subtraction cannot overflow.*


```solidity
function sub(uint256 a, uint256 b) internal pure returns (uint256);
```

### sub

*Returns the subtraction of two unsigned integers, reverting with custom message on
overflow (when the result is negative).
Counterpart to Solidity's `-` operator.
Requirements:
- Subtraction cannot overflow.*


```solidity
function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256);
```

### mul

*Returns the multiplication of two unsigned integers, reverting on
overflow.
Counterpart to Solidity's `*` operator.
Requirements:
- Multiplication cannot overflow.*


```solidity
function mul(uint256 a, uint256 b) internal pure returns (uint256);
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
function div(uint256 a, uint256 b) internal pure returns (uint256);
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
function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256);
```

