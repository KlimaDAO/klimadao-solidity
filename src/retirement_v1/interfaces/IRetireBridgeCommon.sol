// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IRetireBridgeCommon {
    function getNeededBuyAmount(
        address _sourceToken,
        address _poolToken,
        uint256 _poolAmount,
        bool _retireSpecific
    ) external view returns (uint256, uint256);

    function getSwapPath(address _sourceToken, address _poolToken)
        external
        view
        returns (address[] memory);

    function poolRouter(address _poolToken) external view returns (address);
}
