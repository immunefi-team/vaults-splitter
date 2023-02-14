// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import { Splitter } from "../../src/Splitter.sol";

import { ERC20PresetMinterPauser } from "openzeppelin-contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract SplitterTest is Test {
    address owner;
    address payable feeRecipient;
    Splitter splitter;

    address tokenOwner;
    ERC20PresetMinterPauser token;

    function setUp() public {
        owner = vm.addr(1);
        feeRecipient = payable(vm.addr(2));

        splitter = new Splitter(1_500, 1_000, owner, feeRecipient);

        tokenOwner = vm.addr(2);
        vm.prank(tokenOwner);
        token = new ERC20PresetMinterPauser("TestToken", "TTT");
    }

    function testRecoverStuckETH() public {
        // should be able to recover

        // test prep
        uint256 stuckFunds = 0.1 ether;

        vm.deal(address(splitter), stuckFunds);

        // test exec
        uint256 preBalanceOwner = owner.balance;

        vm.prank(owner);
        splitter.withdrawERC20ETH(address(0));

        uint256 postBalanceOwner = owner.balance;

        // test asserts
        assertEq(address(splitter).balance, 0); // no more funds in the splitter
        assertEq(postBalanceOwner - preBalanceOwner, stuckFunds); // funds get back to owner
    }

    function testRecoverStuckERC20() public {
        // should be able to recover

        // test prep
        uint256 stuckFunds = 0.1 ether;

        vm.prank(tokenOwner);
        token.mint(address(splitter), stuckFunds);

        // test exec
        uint256 preBalanceOwner = token.balanceOf(owner);

        vm.prank(owner);
        splitter.withdrawERC20ETH(address(token));

        uint256 postBalanceOwner = token.balanceOf(owner);

        // test asserts
        assertEq(token.balanceOf(address(splitter)), 0); // no more funds in the splitter
        assertEq(postBalanceOwner - preBalanceOwner, stuckFunds); // funds get back to owner
    }

    function testRecoverStuckETHOnlyOwner() public {
        // only owner can call

        address anyone = vm.addr(3);
        assertTrue(anyone != owner);

        // test
        vm.prank(owner);
        splitter.withdrawERC20ETH(address(0)); // should not fail

        vm.prank(anyone);
        vm.expectRevert("Ownable: caller is not the owner");
        splitter.withdrawERC20ETH(address(0));
    }

    function testCannotStuckETH() public {
        // try to send more than expected, will refund

        // test prep
        address project = vm.addr(3);
        address payable whitehat = payable(vm.addr(4));

        uint256 amount = 1 ether;
        uint256 fee = (splitter.fee() * amount) / splitter.FEE_BASIS();

        uint256 payout = amount;

        Splitter.ERC20Payment[] memory erc20Payout = new Splitter.ERC20Payment[](0);

        uint256 introducedError = 0.1 ether;
        uint256 ethToFillAndSend = payout + fee + introducedError;
        hoax(project, ethToFillAndSend);

        // test exec
        splitter.payWhitehat{ value: ethToFillAndSend }("referenceId", whitehat, erc20Payout, payout, 25_000);

        // test assert
        assertEq(address(splitter).balance, 0);
    }

    function testETHDistribution() public {
        // test prep
        address project = vm.addr(3);
        address payable whitehat = payable(vm.addr(4));

        uint256 amount = 1 ether;
        uint256 fee = (splitter.fee() * amount) / splitter.FEE_BASIS();

        uint256 payout = amount;

        Splitter.ERC20Payment[] memory erc20Payout = new Splitter.ERC20Payment[](0);

        uint256 ethToFillAndSend = payout + fee;
        hoax(project, ethToFillAndSend);

        // test exec
        uint256 whitehatPreBalance = address(whitehat).balance;
        uint256 feeRecipientPreBalance = address(splitter.feeRecipient()).balance;
        splitter.payWhitehat{ value: ethToFillAndSend }("referenceId", whitehat, erc20Payout, payout, 25_000);

        // test assert
        assertEq(address(splitter).balance, 0);
        assertEq(address(whitehat).balance - whitehatPreBalance, payout);
        assertEq(address(splitter.feeRecipient()).balance - feeRecipientPreBalance, fee);
    }

    function testERC20Distribution() public {
        // test prep
        address project = vm.addr(3);
        address payable whitehat = payable(vm.addr(4));

        uint256 amount = 1 ether;
        uint256 fee = (splitter.fee() * amount) / splitter.FEE_BASIS();

        uint256 payout = amount;

        Splitter.ERC20Payment[] memory erc20Payout = new Splitter.ERC20Payment[](1);
        erc20Payout[0] = Splitter.ERC20Payment({ token: address(token), amount: payout });

        uint256 tokenToMint = payout + fee;
        vm.prank(tokenOwner);
        token.mint(project, tokenToMint);

        // test exec
        uint256 whitehatPreBalance = token.balanceOf(whitehat);
        uint256 feeRecipientPreBalance = token.balanceOf(splitter.feeRecipient());

        vm.startPrank(project);
        token.approve(address(splitter), tokenToMint);
        splitter.payWhitehat("referenceId", whitehat, erc20Payout, 0, 25_000);

        // test assert
        assertEq(token.balanceOf(address(splitter)), 0);
        assertEq(token.balanceOf(whitehat) - whitehatPreBalance, payout);
        assertEq(token.balanceOf(splitter.feeRecipient()) - feeRecipientPreBalance, fee);
    }
}
