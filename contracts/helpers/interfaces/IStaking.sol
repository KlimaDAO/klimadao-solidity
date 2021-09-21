
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IStaking {
    function stake( uint _amount, address _recipient ) external returns ( bool );
}
