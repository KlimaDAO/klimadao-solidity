
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface ITreasury {
    function deposit( uint _amount, address _token, uint _profit ) external returns ( bool );
    function valueOf( address _token, uint _amount ) external view returns ( uint value_ );
}
