// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface IToucanPool {
    function redeemAuto2(uint amount) external returns (address[] memory tco2s, uint[] memory amounts);

    function redeemMany(address[] calldata erc20s, uint[] calldata amounts) external;

    function feeRedeemPercentageInBase() external pure returns (uint);

    function feeRedeemDivider() external pure returns (uint);

    function redeemFeeExemptedAddresses(address) external view returns (bool);
}

interface IToucanCarbonOffsets {
    function retire(uint amount) external;

    function retireAndMintCertificate(
        string calldata retiringEntityString,
        address beneficiary,
        string calldata beneficiaryString,
        string calldata retirementMessage,
        uint amount
    ) external;

    function mintCertificateLegacy(
        string calldata retiringEntityString,
        address beneficiary,
        string calldata beneficiaryString,
        string calldata retirementMessage,
        uint amount
    ) external;
}
