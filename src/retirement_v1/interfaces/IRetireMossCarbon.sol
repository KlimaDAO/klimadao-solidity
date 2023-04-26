// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IRetireMossCarbon {
    function retireMoss(
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
        uint256 _poolAmount,
        bool _retireSpecific
    ) external view returns (uint256, uint256);
}
