// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface ICarbonContractRegistry {
    function getTokenVaultBeaconAddress() external view returns (address);

    function getVerifiedVaultAddress(uint256 id) external view returns (address);

    function getSerializationAddress(string calldata serialization) external view returns (address);

    function getProjectAddressFromId(uint256 projectId) external view returns (address);

    function getProjectIdFromAddress(address projectAddress) external view returns (uint256);

    function getBeaconAddress() external view returns (address);
}

interface IProject {
    function retire(
        uint256 tokenId,
        uint256 amount,
        address beneficiary,
        string memory retireeName,
        string memory customUri,
        string memory comment,
        bytes memory data
    ) external returns (uint256 nftTokenId);
}
