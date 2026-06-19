// SPDX-License-Identifier: MIT

pragma solidity ^0.8.33;

import {Script, console} from "forge-std/Script.sol";
import {Drips} from "src/Drips.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 constant ROOT = 0x81487c88bb488a9881e46ac77a41728e5add2202d8def038edb07485f9d5b742;
    uint256 constant AMOUNT_TO_FUND = 4 * 25 ether;
    Drips token;
    MerkleAirdrop airdrop;

    function run() public returns (Drips, MerkleAirdrop) {
        vm.startBroadcast();
        token = new Drips();
        airdrop = new MerkleAirdrop(ROOT, IERC20(address(token)));

        // fund airdrop
        token.mint(address(airdrop), AMOUNT_TO_FUND);

        vm.stopBroadcast();
        return (token, airdrop);
    }
}
