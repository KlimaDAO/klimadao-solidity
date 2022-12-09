// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface IToucanPool {
    function redeemAuto2(uint256 amount) external returns (address[] memory tco2s, uint256[] memory amounts);

    function redeemMany(address[] calldata erc20s, uint256[] calldata amounts) external;

    function feeRedeemPercentageInBase() external pure returns (uint256);

    function feeRedeemDivider() external pure returns (uint256);

    function redeemFeeExemptedAddresses(address) external view returns (bool);
}

interface IToucanCarbonOffsets {
    function retire(uint256 amount) external;

    function retireAndMintCertificate(
        string calldata retiringEntityString,
        address beneficiary,
        string calldata beneficiaryString,
        string calldata retirementMessage,
        uint256 amount
    ) external;

    function mintCertificateLegacy(
        string calldata retiringEntityString,
        address beneficiary,
        string calldata beneficiaryString,
        string calldata retirementMessage,
        uint256 amount
    ) external;
}
