// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IKlimaCarbonRetirements {
    function carbonRetired(
        address _retiree,
        address _pool,
        uint256 _amount,
        string calldata _beneficiaryString,
        string calldata _retirementMessage
    ) external;

    function getUnclaimedTotal(address _minter) external view returns (uint256);

    function offsetClaimed(address _minter, uint256 _amount)
        external
        returns (bool);

    function getRetirementIndexInfo(address _retiree, uint256 _index)
        external
        view
        returns (
            address,
            uint256,
            string memory
        );

    function getRetirementPoolInfo(address _retiree, address _pool)
        external
        view
        returns (uint256);

    function getRetirementTotals(address _retiree)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );
}
