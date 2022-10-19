


// ██╗  ██╗██╗     ██╗███╗   ███╗ █████╗     ██████╗  █████╗  ██████╗
// ██║ ██╔╝██║     ██║████╗ ████║██╔══██╗    ██╔══██╗██╔══██╗██╔═══██╗
// █████╔╝ ██║     ██║██╔████╔██║███████║    ██║  ██║███████║██║   ██║
// ██╔═██╗ ██║     ██║██║╚██╔╝██║██╔══██║    ██║  ██║██╔══██║██║   ██║
// ██║  ██╗███████╗██║██║ ╚═╝ ██║██║  ██║    ██████╔╝██║  ██║╚██████╔╝
// ╚═╝  ╚═╝╚══════╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═╝ ╚═════╝

//.            ..          .       .  .            '
//            ''......................'.           .
//             ..                    ..            .
//              ..                  ..             .
//               ..      ....      ..              .
//                ..    ......    ..               .
//                 ..  ..    .. ...                .
//                ...,,.......','...               .
//             ......,;'......';,......            .
//                 ......    .. ..                 .
//                ..    ......   ...               .
//               ..      .'..     ...              .
//              ..                  ..             .
//             ..                    ..            .
//            ...                    .'.           .
//.           ....                  ....           '
//'                                                :

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
/// @title Klima Forward Deposit Contract
/// @author Archimedes


import "../helpers/Ownable.sol";
import "../helpers/interfaces/IERC20.sol";

contract ForwardDeposit is Ownable {

    address public klimaToken;
    address public wsKLIMAToken;
    uint8   public wsKLIMABonusRequired; // wsKLIMA required as a % of the total collateral (ex 100% collateral + 25% bonus in wsKLIMA for 125% collateral) 3 digits

    mapping(address => bool) public allowedFinancers;
    mapping(address => bool) public allowedCollateral;   // Collateral used for the financing BCT/NCT/UBO/NBO/MCO2/etc
    mapping(address => bool) public allowedDepositToken; // Allowed types of deposit tokens USDC/DAI/USDT/FRAX/etc
    mapping(uint256 => bool) public isActiveTermsID;

    ForwardTerms[] public termsRecords; // push only for record keeping

    struct ForwardTerms {
        uint256 expiry;                 // in Epoch terms
        uint256 totalFinancing;         // in USD terms normalized to 18 Decimals (looking at you USDC)
        uint256 totalCarbonCollateral;  // Collateral required for 100% finance unlock in carbon tons
        uint256 financingDeposited;     // amount of financing deposited up to but less than the total
        uint256 collateralDeposited;    // amount of collateral deposited up to but less than the total
        uint256 wsKLIMADeposited;       // amount of wsKLIMA deposited
        uint256 financingBorrowed;      // amount of financing withdrawn by the project
        uint256 tonsDelivered;          // amount of tons delivered to the contract
        address tonsDeliveryAddress;    // address of the TCO2, C3T or other of the tons to be delivered (may be populated later)
        address allowedDepositor;       // address of the allowed depositing address
    }

    event newTermsSet(ForwardTerms setTerms);

    modifier onlyAllowedFinancers() {
        require( allowedFinancers[msg.sender] == true, "Allowed Financer: Caller is not an allowed financer");
        _;
    }

    constructor(address _klimaToken, address _wsklimaToken, uint8 _klimaFee) {

        klimaToken = _klimaToken;
        wsKLIMAToken = _wsklimaToken;
        wsKLIMABonusRequired = _klimaFee;

    }


    //@dev create new set of terms to be used by two parties within the Klima Forward Program

    function setNewTerms(uint256 _expiry, uint256 _totalFinancing, uint256 _totalCarbonCollateral, address _allowedDepositor) public onlyManager {

        ForwardTerms memory TempTerms;

        TempTerms.expiry = _expiry;
        TempTerms.totalFinancing = _totalFinancing;
        TempTerms.totalCarbonCollateral = _totalCarbonCollateral;
        TempTerms.allowedDepositor = _allowedDepositor;

        isActiveTermsID[termsRecords.length] == true;

        termsRecords.push(TempTerms);

        emit newTermsSet(TempTerms);

    }

    //@dev finance the terms set out in a specific ID
    function financeTerms(address financingToken, uint256 termsID, uint256 amount) public onlyAllowedFinancers {
            require(allowedDepositToken[financingToken] == true, "Financing Token Not Allowed");
            require(isActiveTermsID[termsID] == true, "Terms ID not Active");
            require(termsRecords[termsID].financingDeposited + amount <= termsRecords[termsID].totalFinancing, "Amount exceeds the remaining financing available");
            // This check is only for USDC which runs a 6 decimal contract
            if(IERC20(financingToken).decimals() < 18){
                require(termsRecords[termsID].financingDeposited + (amount * (10e12)) <= termsRecords[termsID].totalFinancing, "Amount exceeds the remaining financing available");
            }
            // Transfer asset
            IERC20(financingToken).transferFrom(msg.sender, address(this), amount);

            // Again correct for USDC, all deposits must be noted in Decimal 18 terms
            if(IERC20(financingToken).decimals() < 18){
                termsRecords[termsID].financingDeposited += (amount * (10e12));
            }
            else {
                termsRecords[termsID].financingDeposited += amount;
            }

    }


    //@dev deposit an amount of carbon collateral specified in terms up to a maximum amount
    //@param _collateralAddress token address of the collateral to transfer (UBO/NBO/NCT/BCT/MCO2 as ERC20)
    //@param amount Amount to deposit in Decimal 18 (Assumes 18)
    function depositCarbonCollateral(address _collateralAddress, uint256 termsID, uint256 amount) public {
            require(allowedCollateral[_collateralAddress] == true, "Collateral Token Not Allowed");
            require(isActiveTermsID[termsID] == true, "Terms ID not Active");
            require(termsRecords[termsID].allowedDepositor == msg.sender, "Depositor not allowed");
            require(termsRecords[termsID].collateralDeposited + amount <= termsRecords[termsID].totalCarbonCollateral, "Amount exceeds the remaining collateral required");

            // Transfer asset
            IERC20(_collateralAddress).transferFrom(msg.sender, address(this), amount);
            // Update Record
            termsRecords[termsID].collateralDeposited += amount;

    }

    //@dev deposit an amount of wsKLIMA collateral specified as a percentage of the amount deposited
    function depositwsKLIMACollateral(uint256 termsID) public {
            require(termsRecords[termsID].collateralDeposited > 0, "No carbon collateral deposited");
            require(isActiveTermsID[termsID] == true, "Terms ID not Active");
            require(termsRecords[termsID].allowedDepositor == msg.sender, "Depositor not allowed");

            // Calculate required wsKLIMA
            uint256 amountToTxfr = getwsKLIMACollateralRequired(termsID);
            // Transfer wsKLIMA here
            IERC20(wsKLIMAToken).transferFrom(msg.sender,address(this), amountToTxfr);
            // Update record
            termsRecords[termsID].wsKLIMADeposited += amountToTxfr;


    }
    //@dev withdraw wsKLIMA deposited by a terms owner, checks if any financing was withdrawn and subtracts that from possible amount
    //

    function withdrawWsKLIMACollateral(uint256 termsID, uint256 amount) public {
            require(termsRecords[termsID].wsKLIMADeposited > 0, "No wsKLIMA collateral deposited");
            require(isActiveTermsID[termsID] == true, "Terms ID not Active");
            require(termsRecords[termsID].allowedDepositor == msg.sender, "Depositor not allowed");

            uint256 maxAmountToWithdraw = getWithdrawableWSKLIMA(termsID);

            require(amount <= maxAmountToWithdraw, "Amount to withdraw exceeds allowable amount");

            termsRecords[termsID].wsKLIMADeposited -= amount;

            IERC20(wsKLIMAToken).transferFrom(address(this), msg.sender, amount);


    }
    //@dev withdraw collateral by a terms owner, checks if any financing was withdrawn and subtracts that from possible amount

    function withdrawCollateral(uint256 termsID, address _collateralAddress, uint256 amount) public {
            require(termsRecords[termsID].collateralDeposited > 0, "No collateral deposited");
            require(isActiveTermsID[termsID] == true, "Terms ID not Active");
            require(termsRecords[termsID].allowedDepositor == msg.sender, "Depositor not allowed");

            uint256 maxAmountToWithdraw = getWithdrawableCollateral(termsID);

            require(amount <= maxAmountToWithdraw, "Amount to withdraw exceeds allowable amount");

            IERC20(_collateralAddress).transferFrom(address(this), msg.sender, amount);

            termsRecords[termsID].collateralDeposited -= amount;


    }
    //@dev withdraw available financing for a terms specified by the agreement

    function withdrawFinancing(uint256 termsID, uint256 amount, address financingToken) public {
            require(termsRecords[termsID].collateralDeposited > 0, "No collateral deposited");
            require(termsRecords[termsID].wsKLIMADeposited > 0, "No wsKLIMA collateral deposited");  
            require(isActiveTermsID[termsID] == true, "Terms ID not Active");
            require(termsRecords[termsID].allowedDepositor == msg.sender, "Depositor not allowed");

            uint256 maxAmountToWithdraw = getWithdrawableFinancing(termsID);

            if(IERC20(financingToken).decimals() < 18){
                //normalize to 18 decimals
                require((amount * 10e12) <= maxAmountToWithdraw, "Amount to withdraw exceeds allowable amount");

            }
            else {
                require(amount <= maxAmountToWithdraw, "Amount to withdraw exceeds allowable amount");
            }
            
            IERC20(financingToken).transferFrom(address(this), msg.sender, amount);

            termsRecords[termsID].financingBorrowed += amount;


    }
    //@dev emergency return all funds and close financing in a given termsID, amounts are to be manually calculated to be able to subtract tons delivered/collateral
    function emergencyCloseTerms(uint256 termsID, address[] memory financingTokens, uint256[] memory amounts, address[] memory collateralTokensUsed, uint256[] memory collateralAmounts) public onlyManager {
        require(isActiveTermsID[termsID] == true, "Terms ID not Active");


                    for(uint i = 0 ; i < financingTokens.length ; i++){

                IERC20(financingTokens[i]).transferFrom(address(this), msg.sender, amounts[i]);
            }

            uint256 wsKLIMAtoTxfr = getWithdrawableWSKLIMA(termsID);

            IERC20(wsKLIMAToken).transferFrom(address(this), msg.sender, (termsRecords[termsID].wsKLIMADeposited-wsKLIMAtoTxfr));
            IERC20(wsKLIMAToken).transferFrom(address(this), msg.sender, (termsRecords[termsID].wsKLIMAtoTxfr));


            IERC20(termsRecords[termsID].tonsDeliveryAddress).transferFrom(address(this), msg.sender, termsRecords[termsID].tonsDelivered);


            // TODO: Rework this to either be 1 token per TermsID or accept a mapping. Applies to other functions like Liquidate as well. 
            for(uint j = 0 ; j < collateralTokensUsed.length; j++){

                IERC20(collateralTokensUsed[j]).transferFrom(address(this),msg.sender , collateralAmounts[j]);
            }

            isActiveTermsID[termsID] == false;


    }

    //@dev in the event of the terms expiring, the collateral is liquidated for the amount that is within the terms. 
    //     Liquidation amounts will be manually calculated as hopefully this will be rare.

    function liquidateCollateral(uint256 termsID, address[] memory financingTokens, uint256[] memory amounts, address[] memory collateralTokensUsed, uint256[] memory collateralAmounts) public onlyManager {
            require(isActiveTermsID[termsID] == true, "Terms ID not Active");
            require(block.timestamp > termsRecords[termsID].expiry, "Terms not yet expired");


            for(uint i = 0 ; i < financingTokens.length ; i++){

                IERC20(financingTokens[i]).transferFrom(address(this), msg.sender, amounts[i]);
            }

            IERC20(wsKLIMAToken).transferFrom(address(this), msg.sender, termsRecords[termsID].wsKLIMADeposited);
            IERC20(termsRecords[termsID].tonsDeliveryAddress).transferFrom(address(this), msg.sender, termsRecords[termsID].tonsDelivered);

            for(uint j = 0 ; j < collateralTokensUsed.length; j++){

                IERC20(collateralTokensUsed[j]).transferFrom(address(this), msg.sender, collateralAmounts[j]);
            }

            isActiveTermsID[termsID] == false;


    }

    //@dev calculate withdrawable financing for a given ratio of collateral deposited in a termsID

    function getWithdrawableFinancing(uint256 termsID) public view returns (uint256 withdrawableAmount) {

            withdrawableAmount =  (termsRecords[termsID].collateralDeposited/termsRecords[termsID].totalCarbonCollateral) * termsRecords[termsID].financingDeposited;

            return withdrawableAmount;


    }

    //@dev use this function to deliver tonnage and return collateral and wsKLIMA to the project user

    function deliverTons(uint256 termsID, uint256 amount, address _collateralAddress) public  {

        require(isActiveTermsID[termsID] == true, "Terms ID not Active");
        require(termsRecords[termsID].allowedDepositor == msg.sender, "Depositor not allowed");

        IERC20(termsRecords[termsID].tonsDeliveryAddress).transferFrom(msg.sender,address(this), amount);

        termsRecords[termsID].tonsDelivered += amount;

        uint256 amountWSKLIMAToTxfr = getWithdrawableWSKLIMA(termsID);

        IERC20(wsKLIMAToken).transferFrom(address(this), msg.sender, amountWSKLIMAToTxfr);

        termsRecords[termsID].wsKLIMADeposited -= amountWSKLIMAToTxfr;

        uint256 collateralToTxfr = getWithdrawableCollateral(termsID);

        IERC20(_collateralAddress).transferFrom(address(this), msg.sender, collateralToTxfr);

        termsRecords[termsID].collateralDeposited -= collateralToTxfr;


    }

    //@dev calculate wsKLIMA that is withdrawable, which is only withdrawable after tons are delivered or on liquidation

    function getWithdrawableWSKLIMA(uint256 termsID) public view returns (uint256 withdrawableAmount){

            withdrawableAmount =  (termsRecords[termsID].tonsDelivered/termsRecords[termsID].totalCarbonCollateral) * termsRecords[termsID].wsKLIMADeposited;

            return withdrawableAmount;


    }

    //@dev calculate how much collateral can be withdrawn based on the amount financed

    function getWithdrawableCollateral(uint256 termsID) public view returns (uint256 withdrawableAmount){

            uint256 lockedAmount = (termsRecords[termsID].financingBorrowed/termsRecords[termsID].totalFinancing) * termsRecords[termsID].collateralDeposited;

            withdrawableAmount = termsRecords[termsID].collateralDeposited - lockedAmount;

            return withdrawableAmount;


    }

    //@dev calculate the required wsKLIMA for withdrawing financing

    function getwsKLIMACollateralRequired(uint256 termsID) public view returns (uint256 amountToTransfer) {

        amountToTransfer = (termsRecords[termsID].collateralDeposited * wsKLIMABonusRequired)/1000;

        return amountToTransfer;

    }


    function updateTonsDeliveryAddress(uint256 termsID, address _newDeliveryAddress) public onlyManager {

       require(isActiveTermsID[termsID] == true, "Terms ID not Active");
       termsRecords[termsID].tonsDeliveryAddress = _newDeliveryAddress;     

    }

    //@dev updates the state of a financer
    function updateAllowedFinancer(address _financerToEdit, bool _newState) public onlyManager {

        allowedFinancers[_financerToEdit] = _newState;

    }
    //@dev updates the state of a depositor
    function updateAllowedDepositor(uint256 termsID, address _newDepositor) public onlyManager {

        require(isActiveTermsID[termsID] == true, "Terms ID not Active");
        termsRecords[termsID].allowedDepositor = _newDepositor;

    }

    //@dev updates collateral tokens
    function updateAllowedCollateral(address _collateralTokenAddress, bool _newState) public onlyManager {

        allowedCollateral[_collateralTokenAddress] = _newState;

    }
    //@dev updates deposit tokens
    function updateAllowedDepositToken(address _depositTokenAddress, bool _newState) public onlyManager {

        allowedDepositToken[_depositTokenAddress] = _newState;
        
    }

    function updateKlimaFee(uint8 _newFee) public onlyManager {
        wsKLIMABonusRequired = _newFee;
    }

}