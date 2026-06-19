// SPDX-License-Identifier: MIT

pragma solidity ^0.8.33;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MerkleAirdrop {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                                 Errors
    //////////////////////////////////////////////////////////////*/
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__HasClaimed();

    /*//////////////////////////////////////////////////////////////
                             State Variables
    //////////////////////////////////////////////////////////////*/
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address => bool) private s_hasClaimed;

    /*//////////////////////////////////////////////////////////////
                             Events
    //////////////////////////////////////////////////////////////*/
    event Claim(address indexed account, uint256 amount);

    constructor(bytes32 _merkleRoot, IERC20 _airdropToken) {
        i_merkleRoot = _merkleRoot;
        i_airdropToken = _airdropToken;
    }

    /*//////////////////////////////////////////////////////////////
                             External Functions
    //////////////////////////////////////////////////////////////*/
    function claim(address _account, uint256 _amount, bytes32[] calldata _merkleProof) external {
        // double hash leaf to guard against node as leaf attack
        // (passing a intermediate hash as a leaf)

        if (s_hasClaimed[_account]) {
            revert MerkleAirdrop__HasClaimed();
        }

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_account, _amount))));

        if (!MerkleProof.verify(_merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        s_hasClaimed[_account] = true;

        emit Claim(_account, _amount);

        i_airdropToken.safeTransfer(_account, _amount);
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
