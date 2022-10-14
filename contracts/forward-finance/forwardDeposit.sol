


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
/// @title Klima Future Financing Contract
/// @author Archimedes


import "../helpers/Ownable.sol";

contract ForwardDeposit is Ownable {

    address public klimaToken;

    mapping(address => bool) public allowedFinancers;
    mapping(address => bool) public allowedCollateral;
    mapping(address => bool) public allowedDepositToken;
    mapping(uint256 => bool) public isActiveTermsID;

    ForwardTerms[] public termsRecords; // push only for record keeping

    struct ForwardTerms {
        uint256 expiry;                 //in Epoch terms
        uint256 totalFinancing;         // in USD terms normalized to 18 Decimals (looking at you USDC)
        uint256 totalCarbonCollateral;  // Collateral required for 100% finance unlock in carbon tons
        uint256 financingDeposited;     // amount of financing deposited up to but less than the total
        uint256 collateralDeposited;    // amount of collateral deposited up to but less than the total
        uint256 financingBorrowed;      //amount of financing withdrawn by the project
        uint256 tonsDelivered;          // amount of tons delivered to the contract
        address tonsDeliveryAddress;    // address of the TCO2, C3T or other of the tons to be delivered (may be populated later)
        address allowedDepositor;       // address of the allowed depositing address
    }

    event newTermsSet(ForwardTerms setTerms);



    constructor(address _klimaToken) {

        klimaToken = _klimaToken;

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

    //@dev 
    function 

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

}