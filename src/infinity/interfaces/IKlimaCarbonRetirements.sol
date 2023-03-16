// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IKlimaCarbonRetirements {
    function carbonRetired(
        address _retiree,
        address _pool,
        uint _amount,
        string calldata _beneficiaryString,
        string calldata _retirementMessage
    ) external;

    function getUnclaimedTotal(address _minter) external view returns (uint);

    function offsetClaimed(address _minter, uint _amount) external returns (bool);

    function getRetirementIndexInfo(address _retiree, uint _index)
        external
        view
        returns (address, uint, string memory, string memory);

    function getRetirementPoolInfo(address _retiree, address _pool) external view returns (uint);

    function getRetirementTotals(address _retiree) external view returns (uint, uint, uint);
}
