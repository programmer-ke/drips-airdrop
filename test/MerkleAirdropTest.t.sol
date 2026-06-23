// SPDX-License-Identifier: MIT

pragma solidity ^0.8.33;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {Drips} from "src/Drips.sol";
import {DeployMerkleAirdrop} from "script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop public airdrop;
    Drips public token;
    DeployMerkleAirdrop deployer;

    bytes32 public ROOT = 0x81487c88bb488a9881e46ac77a41728e5add2202d8def038edb07485f9d5b742;
    uint256 public AMOUNT_PER_USER = 25 ether;
    uint256 public AMOUNT_TO_FUND_CONTRACT;

    address user;
    uint256 userPrivateKey;

    address public gasPayer;

    bytes32 proofOne = 0x875631ab70d5c9a1430b5a44e60c2c218f68a62a01a73b2e49d03f130b04b5c9;
    bytes32 proofTwo = 0x0fb85f7b6df160de3a55fbbc3757e1166f70d574c0b5520e22040ad2b88d7a5d;
    bytes32[] public PROOF = [proofOne, proofTwo];

    function setUp() public {
        (user, userPrivateKey) = makeAddrAndKey("USER");
        gasPayer = makeAddr("gasPayer");

        deployer = new DeployMerkleAirdrop();
        (token, airdrop) = deployer.run();
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);

        // let user sign message
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_PER_USER);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);

        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_PER_USER, PROOF, v, r, s);

        uint256 endingBalance = token.balanceOf(user);

        assertEq(
            endingBalance - startingBalance, AMOUNT_PER_USER, "User did not receive claim amount"
        );
    }
}

