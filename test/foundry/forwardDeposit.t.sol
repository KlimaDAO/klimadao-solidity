// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../contracts/forward-finance/forwardDeposit.sol";

contract ForwardDepositTest is Test {
    ForwardDeposit public fd;
    address public me = vm.addr(1);

    function setUp() public {
        vm.prank(me);
        fd = new ForwardDeposit( address(0), address(1), 0);
    }

    function testManager() public {
        
        vm.startPrank(me);
        /*vm.deal(me, 1 ether);*/
        emit log_address(fd.manager());
        emit log_address(me);

        assertEq(fd.manager(), me);

        vm.stopPrank();
    }

}
