// SPDX-License-Identifier: MIT

pragma solidity ^0.8.33;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {
    address CLAIMING_ADDRESS = 0xF921F4FA82620d8D2589971798c51aeD0C02c81a;
    uint256 CLAIMING_AMOUNT = 25 ether;
    bytes32 PROOF_ONE = 0x875631ab70d5c9a1430b5a44e60c2c218f68a62a01a73b2e49d03f130b04b5c9;
    bytes32 PROOF_TWO = 0x0fb85f7b6df160de3a55fbbc3757e1166f70d574c0b5520e22040ad2b88d7a5d;
    bytes32[] proof = [PROOF_ONE, PROOF_TWO];
    // Created via `make sign`
    bytes private SIGNATURE =
        hex"82a92fb5d8f8fe65a15f00e4c3d662bb4dcf70d24f6e8bcc858c26a4017a95ff728b70aa938430f7687cfb9cdd20c633877f28dd94ef4a679d46e7ddeb88caa21b";

    function run() external {
        address mostRecentlyDeployed =
            DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }

    function claimAirdrop(address airdrop) public {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);

        vm.startBroadcast();
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, proof, v, r, s);
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
