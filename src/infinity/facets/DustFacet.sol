// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import "../ReentrancyGuard.sol";

/**
 * @author Cujo
 * @title Dust Facet sends any pool dust to the Klima Treasury
 */
contract DustFacet is ReentrancyGuard {
    using SafeERC20 for IERC20;

    function sendDust() external payable {
        LibDiamond.enforceIsContractOwner();

        uint256 bctBalance = IERC20(C.bct()).balanceOf(address(this));
        uint256 nctBalance = IERC20(C.nct()).balanceOf(address(this));
        uint256 mco2Balance = IERC20(C.mco2()).balanceOf(address(this));
        uint256 uboBalance = IERC20(C.ubo()).balanceOf(address(this));
        uint256 nboBalance = IERC20(C.nbo()).balanceOf(address(this));
        uint256 usdcBalance = IERC20(C.usdc()).balanceOf(address(this));

        if (bctBalance > 0) IERC20(C.bct()).safeTransfer(C.treasury(), bctBalance);
        if (nctBalance > 0) IERC20(C.nct()).safeTransfer(C.treasury(), nctBalance);
        if (mco2Balance > 0) IERC20(C.mco2()).safeTransfer(C.treasury(), mco2Balance);
        if (uboBalance > 0) IERC20(C.ubo()).safeTransfer(C.treasury(), uboBalance);
        if (nboBalance > 0) IERC20(C.nbo()).safeTransfer(C.treasury(), nboBalance);
        if (usdcBalance > 0) IERC20(C.usdc()).safeTransfer(C.treasury(), usdcBalance);
    }
}
