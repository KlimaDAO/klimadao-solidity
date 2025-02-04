interface ICMARKCreditToken {
    function retire(uint256 amount, address beneficiary, string calldata beneficiaryName, string calldata message, string calldata consumptionCountryCode) external;
    function retireFrom(uint256 amount, address beneficiary, string calldata beneficiaryName, string calldata message, string calldata consumptionCountryCode, address account) external;
}

interface ICMARKCreditTokenFactory {
    function creditAddressToId(address) external view returns (string memory);
    function creditIdToAddress(string calldata) external view returns (address);
    function issueCredits(string calldata, uint256, address) external;
}
