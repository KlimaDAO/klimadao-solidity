pragma solidity ^0.8.16;

interface ICRProject {
    function totalSupply(uint256 tokenId) external view returns (uint256);

    function owner() external returns (address owner);
}
