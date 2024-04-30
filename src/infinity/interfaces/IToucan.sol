// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface IToucanPool {
    function redeemAuto2(uint256 amount) external returns (address[] memory tco2s, uint256[] memory amounts);

    function redeemMany(address[] calldata erc20s, uint256[] calldata amounts) external;

    function feeRedeemPercentageInBase() external pure returns (uint256);

    function feeRedeemDivider() external pure returns (uint256);

    function redeemFeeExemptedAddresses(address) external view returns (bool);

    function getScoredTCO2s() external view returns (address[] memory);
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

    function standardRegistry() external returns (string memory registry);
}

interface IToucanContractRegistry {
    function isValidERC20(address erc20) external returns (bool);
}

interface IToucanPuroCarbonOffsets {
    struct CreateRetirementRequestParams {
        uint256[] tokenIds;
        uint256 amount;
        string retiringEntityString;
        address beneficiary;
        string beneficiaryString;
        string retirementMessage;
        string beneficiaryLocation;
        string consumptionCountryCode;
        uint256 consumptionPeriodStart;
        uint256 consumptionPeriodEnd;
    }

    function requestRetirement(CreateRetirementRequestParams calldata params) external returns (uint256 requestId);
}
