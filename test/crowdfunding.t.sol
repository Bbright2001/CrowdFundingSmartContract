//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {CrowdFunding} from "../src/crowdFunding.sol";

contract testCrowdFunding is Test {
    CrowdFunding public funding;
    address contributor1;
    address contributor2;
    address creator;

    receive() external payable {}

    function setUp() public {
        contributor1 = address(0x1);
        contributor2 = address(0x2);
        creator      = address(this);
        
        funding = new CrowdFunding(2 ether, 10);

        //
        vm.deal(contributor1, 5 ether);
        vm.deal(contributor2, 5 ether);
    }

    function testContributeUpdatesBalance() public {
        vm.prank(contributor1);
        funding.contributeFunds{value: 2 ether}();

        uint balance = funding.contributions(contributor1);
        assertEq(balance, 2 ether);
    }
    function testContributionsAndWithdraw() public {

    // Fund accounts
    vm.deal(contributor1, 5 ether);
    vm.deal(contributor2, 5 ether);

    
    vm.prank(contributor1);
    funding.contributeFunds{value: 1 ether}();

    vm.prank(contributor2);
    funding.contributeFunds{value: 1 ether}();

    assertEq(funding.getTotalAmountContributed(), 2 ether);

    vm.warp(block.timestamp + 11 days);

    uint balanceBefore = creator.balance;
    vm.prank(creator);
    funding.withdrawFunds();
    uint balanceAfter = creator.balance;

    assertGt(balanceAfter, balanceBefore);
    assertEq(address(funding).balance, 0);
}

    function testCannotRefundifDeadlineNotReached() public {
        vm.prank(contributor1);
        funding.contributeFunds{value: 2 ether}();

        vm.warp(block.timestamp + 6 days);

        vm.prank(contributor1);
        vm.expectRevert("Deadline not reached yet");

        funding.refund();
    }
}