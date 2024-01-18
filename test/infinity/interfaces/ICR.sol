pragma solidity ^0.8.16;

interface ICRProject {
    function verifyAndMintExPost(
        address verificationVault,
        uint256 tokenId,
        uint256 amountVerified,
        uint256 amountToAnteHolders,
        uint256 verificationPeriodStart,
        uint256 verificationPeriodEnd,
        string memory monitoringReport
    ) external;

    function owner() external returns (address owner);
}
