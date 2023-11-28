// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

// solhint-disable no-global-import
import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import { Splitter } from "../../src/Splitter.sol";

import { ERC20PresetMinterPauser } from "openzeppelin-contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract SplitterTest is Test {
    // solhint-disable state-visibility
    address owner;
    address payable feeRecipient;
    Splitter splitter;

    address tokenOwner;
    ERC20PresetMinterPauser token;

    uint256 gasCap;
    uint256 maxFee;

    event PayWhitehat(
        address indexed from,
        bytes32 indexed referenceId,
        address wh,
        Splitter.ERC20Payment[] payout,
        uint256 nativeTokenAmt,
        address feeRecipient,
        uint256 fee
    );

    function setUp() public {
        owner = vm.addr(1);
        feeRecipient = payable(vm.addr(2));

        gasCap = 500_000;
        maxFee = 1_500;

        splitter = new Splitter(gasCap, maxFee, owner, feeRecipient);

        tokenOwner = vm.addr(2);
        vm.prank(tokenOwner);
        token = new ERC20PresetMinterPauser("TestToken", "TTT");
    }

    function testFeeRecipientCannotBeNullOnCreation() public {
        vm.expectRevert("Splitter: FeeRecipient cannot be null address");
        new Splitter(gasCap, 1_500, owner, payable(address(0)));
    }

    function testFeeRecipientCannotBeSetToNull() public {
        vm.startPrank(owner);

        vm.expectRevert("Splitter: FeeRecipient cannot be null address");
        splitter.changeFeeRecipient(payable(address(0)));
    }


    function testCannotStuckETH() public {
        // try to send more than expected, will refund

        // test prep
        address project = vm.addr(3);
        address payable whitehat = payable(vm.addr(4));
        uint256 fee = 1_000;

        uint256 amount = 1 ether;
        uint256 feeAmount = (fee * amount) / splitter.FEE_BASIS();

        uint256 payout = amount;

        Splitter.ERC20Payment[] memory erc20Payout = new Splitter.ERC20Payment[](0);

        vm.expectEmit(true, true, true, true);
        emit PayWhitehat(project, "referenceId", whitehat, erc20Payout, payout, feeRecipient, fee);

        uint256 introducedError = 0.1 ether;
        uint256 ethToFillAndSend = payout + feeAmount + introducedError;
        hoax(project, ethToFillAndSend);

        // test exec
        splitter.payWhitehat{ value: ethToFillAndSend }("referenceId", whitehat, erc20Payout, payout, 25_000, fee);

        // test assert
        assertEq(address(splitter).balance, 0);
    }

    function testRefundEthIfZeroEthAmountInput() public {
        // test prep
        address project = vm.addr(3);
        address payable whitehat = payable(vm.addr(4));
        uint256 fee = 1_000;

        Splitter.ERC20Payment[] memory erc20Payout = new Splitter.ERC20Payment[](0);

        // record events
        vm.recordLogs();

        uint256 ethToFillAndSend = 1 ether;
        hoax(project, ethToFillAndSend);

        // test exec
        splitter.payWhitehat{ value: ethToFillAndSend }("referenceId", whitehat, erc20Payout, 0, 25_000, fee);

        // test assert
        assertEq(address(splitter).balance, 0);
        assertEq(address(whitehat).balance, 0);
        assertEq(address(project).balance, ethToFillAndSend);

        // nothing is actually being sent to the whitehat, test lack of recorded events
        assertEq(vm.getRecordedLogs().length, 0);
    }

    function testETHDistribution() public {
        // test prep
        address project = vm.addr(3);
        address payable whitehat = payable(vm.addr(4));
        uint256 fee = 1_000;

        uint256 amount = 1 ether;
        uint256 feeAmount = (fee * amount) / splitter.FEE_BASIS();

        uint256 payout = amount;

        Splitter.ERC20Payment[] memory erc20Payout = new Splitter.ERC20Payment[](0);

        uint256 ethToFillAndSend = payout + feeAmount;
        hoax(project, ethToFillAndSend);

        // test exec
        uint256 whitehatPreBalance = address(whitehat).balance;
        uint256 feeRecipientPreBalance = address(splitter.feeRecipient()).balance;
        splitter.payWhitehat{ value: ethToFillAndSend }("referenceId", whitehat, erc20Payout, payout, 25_000, fee);

        // test assert
        assertEq(address(splitter).balance, 0);
        assertEq(address(whitehat).balance - whitehatPreBalance, payout);
        assertEq(address(splitter.feeRecipient()).balance - feeRecipientPreBalance, feeAmount);
    }

    function testERC20Distribution() public {
        // test prep
        address project = vm.addr(3);
        address payable whitehat = payable(vm.addr(4));
        uint256 fee = 1_000;

        uint256 amount = 1 ether;
        uint256 feeAmount = (fee * amount) / splitter.FEE_BASIS();

        uint256 payout = amount;

        Splitter.ERC20Payment[] memory erc20Payout = new Splitter.ERC20Payment[](1);
        erc20Payout[0] = Splitter.ERC20Payment({ token: address(token), amount: payout });

        uint256 tokenToMint = payout + feeAmount;
        vm.prank(tokenOwner);
        token.mint(project, tokenToMint);

        // test exec
        uint256 whitehatPreBalance = token.balanceOf(whitehat);
        uint256 feeRecipientPreBalance = token.balanceOf(splitter.feeRecipient());

        vm.startPrank(project);
        token.approve(address(splitter), tokenToMint);
        splitter.payWhitehat("referenceId", whitehat, erc20Payout, 0, 25_000, fee);

        // test assert
        assertEq(token.balanceOf(address(splitter)), 0);
        assertEq(token.balanceOf(whitehat) - whitehatPreBalance, payout);
        assertEq(token.balanceOf(splitter.feeRecipient()) - feeRecipientPreBalance, feeAmount);
    }

    function testGasCap() public {
        // test prep
        address project = vm.addr(3);
        address payable whitehat = payable(vm.addr(4));
        uint256 fee = 1_000;

        uint256 amount = 1 ether;
        uint256 feeAmount = (fee * amount) / splitter.FEE_BASIS();

        uint256 payout = amount;

        Splitter.ERC20Payment[] memory erc20Payout = new Splitter.ERC20Payment[](0);

        uint256 ethToFillAndSend = payout + feeAmount;
        hoax(project, ethToFillAndSend);

        uint256 gasLimit = gasCap + 1;

        // test exec
        vm.expectRevert("Splitter: Gas greater than max allowed");
        splitter.payWhitehat{ value: ethToFillAndSend }("referenceId", whitehat, erc20Payout, payout, gasLimit, fee);
    }

    function testCannotPayNullWhitehat() public {
        // test prep
        address project = vm.addr(3);
        address payable whitehat = payable(address(0));
        uint256 fee = 1_000;

        uint256 amount = 1 ether;
        uint256 feeAmount = (fee * amount) / splitter.FEE_BASIS();

        uint256 payout = amount;

        Splitter.ERC20Payment[] memory erc20Payout = new Splitter.ERC20Payment[](0);

        uint256 ethToFillAndSend = payout + feeAmount;
        hoax(project, ethToFillAndSend);

        uint256 gasLimit = gasCap - 1;

        // test exec
        vm.expectRevert("Splitter: Whitehat address cannot be null");
        splitter.payWhitehat{ value: ethToFillAndSend }("referenceId", whitehat, erc20Payout, payout, gasLimit, fee);
    }
}
