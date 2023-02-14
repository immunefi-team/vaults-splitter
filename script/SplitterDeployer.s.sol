// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/Splitter.sol";

contract SplitterDeployer is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        uint256 maxFee = 15_00;
        uint256 fee = 10_00;
        address owner = vm.envAddress("SPLITTER_OWNER");
        address payable feeRecipient = payable(vm.envAddress("SPLITTER_FEE_RECIPIENT"));

        new Splitter{ salt: "immunefi" }(maxFee, fee, owner, feeRecipient);

        vm.stopBroadcast();
    }
}
