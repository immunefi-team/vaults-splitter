// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

// solhint-disable no-console
import { CommonBase } from "forge-std/Base.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { StdUtils } from "forge-std/StdUtils.sol";
import { console } from "forge-std/console.sol";
import { ERC20PresetMinterPauser } from "openzeppelin-contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import { Splitter } from "../../../src/Splitter.sol";

uint256 constant ETH_SUPPLY = 120_500_000 ether;
uint256 constant TOKEN_SUPPLY = 10_000_000 ether;

contract Handler is CommonBase, StdCheats, StdUtils {
    Splitter public splitter;
    ERC20PresetMinterPauser public token;
    address payable public wh;

    constructor(Splitter _splitter) {
        splitter = _splitter;
        token = new ERC20PresetMinterPauser("TestToken", "TTT");
        deal(address(this), ETH_SUPPLY);
        token.mint(address(this), TOKEN_SUPPLY);
        token.approve(address(splitter), type(uint256).max);
        wh = payable(vm.addr(1000));
    }

    /**
     * @dev Function will call the splitter to pay the whitehat, with bounded random amounts of funds
     * @param nativeTokenAmtSent Amount of native token to send to the splitter through msg.value
     * @param nativeTokenAmtToPay Amount of native token to pay the whitehat
     * @param tokenAmt Amount of token to pay the whitehat
     * @param gasAmt Amount of gas used to pay the whitehat
     */
    function payWhitehat(
        uint256 nativeTokenAmtSent,
        uint256 nativeTokenAmtToPay,
        uint256 tokenAmt,
        uint256 gasAmt
    ) public {
        nativeTokenAmtSent = bound(nativeTokenAmtSent, 0, address(this).balance);
        gasAmt = bound(gasAmt, 0, splitter.gasCap());

        // avoid overflows
        nativeTokenAmtToPay = bound(nativeTokenAmtToPay, 0, nativeTokenAmtSent);
        tokenAmt = bound(tokenAmt, 0, token.balanceOf(address(this)));

        // avoid lack of funds to pay for fees

        uint256 nativeFee = (splitter.fee() * nativeTokenAmtToPay) / splitter.FEE_BASIS();
        nativeTokenAmtToPay = bound(nativeTokenAmtToPay, 0, nativeTokenAmtSent - nativeFee);

        uint256 tokenFee = (splitter.fee() * tokenAmt) / splitter.FEE_BASIS();
        tokenAmt = bound(tokenAmt, 0, token.balanceOf(address(this)) - tokenFee);

        // make the payment
        Splitter.ERC20Payment[] memory erc20Payments = new Splitter.ERC20Payment[](1);
        erc20Payments[0] = Splitter.ERC20Payment(address(token), tokenAmt);

        splitter.payWhitehat{ value: nativeTokenAmtSent }(
            bytes32(nativeTokenAmtSent), // irrelevant, just to make it unique
            wh,
            erc20Payments,
            nativeTokenAmtToPay,
            gasAmt
        );
    }

    // add this to be excluded from coverage report
    function test() public {}

    /**
     * @dev Make the contract payable to get refunds back.
     */
    receive() external payable {}
}
