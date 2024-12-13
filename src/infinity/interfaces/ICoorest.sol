// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.16;

interface ICCO2 {
    function burningPercentage() external view returns (uint256);

    function decimalRatio() external view returns (uint256);
}

interface ICoorest {
    function mintPOCC(uint256 _amountCO2, string memory _reason, string memory _owner)
        external
        payable
        returns (uint256);
}
