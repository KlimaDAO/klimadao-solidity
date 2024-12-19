pragma solidity ^0.8.16;

import "../TestHelper.sol";
import {ICCO2} from "../../../src/infinity/interfaces/ICoorest.sol";
import {ConstantsGetter} from "../../../src/infinity/mocks/ConstantsGetter.sol";
import {CoorestLibraryMock} from "../../../src/infinity/mocks/CoorestLibraryMock.sol";
import {LibCoorestCarbon} from "../../../src/infinity/libraries/Bridges/LibCoorestCarbon.sol";

contract LibCoorestCarbonTest is TestHelper {
    ConstantsGetter constantGetter;
    CoorestLibraryMock coorestLibraryMock;

    function setUp() public {
        constantGetter = new ConstantsGetter();
        coorestLibraryMock = new CoorestLibraryMock();
    }

    function test_infinity_coorestFee(uint256 amount) public {
        vm.assume(amount > 0);
        vm.assume(amount < 1e30);

        vm.mockCall(
            constantGetter.coorestCCO2Token(), abi.encodeWithSelector(ICCO2.burningPercentage.selector), abi.encode(20)
        );

        vm.mockCall(
            address(constantGetter.coorestCCO2Token()),
            abi.encodeWithSelector(ICCO2.decimalRatio.selector),
            abi.encode(10_000)
        );

        uint256 fee = coorestLibraryMock.getSpecificRetirementFee(constantGetter.coorestCCO2Token(), amount);

        vm.clearMockedCalls();
        assertLt(fee, amount);
    }

    function test_infinity_coorestFeeFailsIfBpGtDivisor(uint256 amount) public {
        vm.assume(amount > 0);
        vm.assume(amount < 1e30);

        vm.mockCall(
            address(constantGetter.coorestCCO2Token()),
            abi.encodeWithSelector(ICCO2.burningPercentage.selector),
            abi.encode(20_000)
        );

        vm.mockCall(
            address(constantGetter.coorestCCO2Token()),
            abi.encodeWithSelector(ICCO2.decimalRatio.selector),
            abi.encode(10_000)
        );

        address cco2 = constantGetter.coorestCCO2Token();
        vm.expectRevert(LibCoorestCarbon.FeePercentageGreaterThanDivider.selector);
        coorestLibraryMock.getSpecificRetirementFee(cco2, amount);

        vm.clearMockedCalls();
    }

    function test_infinity_coorestFeeFailsIfDivisorZero(uint256 amount) public {
        vm.assume(amount > 0);
        vm.assume(amount < 1e30);

        vm.mockCall(
            address(constantGetter.coorestCCO2Token()),
            abi.encodeWithSelector(ICCO2.burningPercentage.selector),
            abi.encode(0)
        );

        vm.mockCall(
            address(constantGetter.coorestCCO2Token()),
            abi.encodeWithSelector(ICCO2.decimalRatio.selector),
            abi.encode(0)
        );

        address cco2 = constantGetter.coorestCCO2Token();
        vm.expectRevert(LibCoorestCarbon.FeeRetireDividerIsZero.selector);
        coorestLibraryMock.getSpecificRetirementFee(cco2, amount);

        vm.clearMockedCalls();
    }

    function test_infinity_coorestFeeFailsIfAmountZero() public {
        address cco2 = constantGetter.coorestCCO2Token();
        vm.expectRevert(LibCoorestCarbon.RetireAmountIsZero.selector);
        coorestLibraryMock.getSpecificRetirementFee(cco2, 0);
    }
}
