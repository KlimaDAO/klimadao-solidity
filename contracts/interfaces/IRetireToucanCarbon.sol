// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IRetireToucanCarbon {
    function retireToucan(
        address _sourceToken,
        address _poolToken,
        uint256 _amount,
        bool _amountInCarbon,
        address _beneficiaryAddress,
        string memory _beneficiaryString,
        string memory _retirementMessage,
        address _retiree
    ) external;

    function getNeededBuyAmount(
        address _sourceToken,
        address _poolToken,
        uint256 _poolAmount
    ) external view returns (uint256, uint256);
}
