
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IBondCalculator {
    function valuation( address pair_, uint amount_ ) external view returns ( uint _value );
    function markdown( address _pair ) external view returns ( uint );
}
