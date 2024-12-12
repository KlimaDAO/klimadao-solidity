interface ICMARKCreditToken {
    function retire(uint256 amount, address beneficiary, string beneficiaryName, string message, string consumptionCountryCode) external nonpayable;
    function retireFrom(uint256 amount, address beneficiary, string beneficiaryName, string message, string consumptionCountryCode, address account) external nonpayable;
}

interface ICMARKCreditTokenFactory {

    function creditAddressToId(address) returns (string) external view;
}
