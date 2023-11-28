// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/Splitter.sol";

contract SplitterDeployer is Script {
    function run() external {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));
        uint256 gasCap = 50_000;
        uint256 maxFee = 15_00;
        address owner = vm.envAddress("SPLITTER_OWNER");
        address payable feeRecipient = payable(vm.envAddress("SPLITTER_FEE_RECIPIENT"));

        vm.startBroadcast(deployerPrivateKey);
        new Splitter{ salt: "immunefi" }(gasCap, maxFee, owner, feeRecipient);
        vm.stopBroadcast();
    }
}
