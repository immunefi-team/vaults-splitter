// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { Test } from "forge-std/Test.sol";
import { Splitter } from "../../src/Splitter.sol";
import { Handler } from "./handlers/Handler.sol";

contract SplitterInvariantsTest is Test {
    // solhint-disable state-visibility
    address owner;
    address payable feeRecipient;
    uint256 gasCap;

    Splitter splitter;
    Handler handler;

    function setUp() public {
        owner = vm.addr(1);
        feeRecipient = payable(vm.addr(2));
        gasCap = 500_000;

        splitter = new Splitter(gasCap, 1_500, owner, feeRecipient);

        handler = new Handler(splitter);

        // we specify selectors and target contract to be fuzzed
        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = Handler.payWhitehat.selector;

        targetSelector(FuzzSelector({ addr: address(handler), selectors: selectors }));
        targetContract(address(handler));
    }

    /**
     @dev invariant: should not have any leftover funds from payments
     * It should be noted that the invariant is not that the splitter cannot have stucked funds, 
     * but that the splitter cannot have stucked funds due to payments. 
     * We acknowledge anybody can send funds to the splitter.
     */
    function invariant_noLeftoverFundsFromPayments() public {
        assertEq(address(splitter).balance, 0);
        assertEq(handler.token().balanceOf(address(splitter)), 0);
    }

    // add this to be excluded from coverage report
    function test() public {}
}
