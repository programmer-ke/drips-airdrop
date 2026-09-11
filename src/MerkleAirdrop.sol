// SPDX-License-Identifier: MIT

pragma solidity ^0.8.33;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                                 Errors
    //////////////////////////////////////////////////////////////*/
    error MerkleAirdrop__InvalidSignature();
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__HasClaimed();

    /*//////////////////////////////////////////////////////////////
                             Type Declarations
    //////////////////////////////////////////////////////////////*/
    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    /*//////////////////////////////////////////////////////////////
                             State Variables
    //////////////////////////////////////////////////////////////*/
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address => bool) private s_hasClaimed;
    bytes32 private constant MESSAGE_TYPEHASH =
        keccak256("AirdropClaim(address account,uint256 amount)");

    /*//////////////////////////////////////////////////////////////
                             Events
    //////////////////////////////////////////////////////////////*/
    event Claim(address indexed account, uint256 amount);

    constructor(bytes32 _merkleRoot, IERC20 _airdropToken) EIP712("MerkleAirdrop", "1") {
        i_merkleRoot = _merkleRoot;
        i_airdropToken = _airdropToken;
    }

    /*//////////////////////////////////////////////////////////////
                             External Functions
    //////////////////////////////////////////////////////////////*/
    function claim(
        address _account,
        uint256 _amount,
        bytes32[] calldata _merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (s_hasClaimed[_account]) {
            revert MerkleAirdrop__HasClaimed();
        }

        bytes32 digest = getMessageHash(_account, _amount);

        if (!_isValidSignature(_account, digest, v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
        }

        // double hash leaf to guard against node as leaf attack
        // (passing a intermediate hash as a leaf)
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

    /*//////////////////////////////////////////////////////////////
                             Public Functions
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns a digest of the claim that represents the message that the claimant signs
    /// @param account The account authorizing the claim
    /// @param amount The amount associated with the claim
    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))
        );

        // return the hashed message with the expected Typed Data structure of EIP712
        return _hashTypedDataV4(structHash);
    }

    /*//////////////////////////////////////////////////////////////
                             Internal Functions
    //////////////////////////////////////////////////////////////*/
    function _isValidSignature(
        address expectedSigner,
        bytes32 messageHash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (bool) {
        (address actualSigner,,) = ECDSA.tryRecover(messageHash, v, r, s);
        return actualSigner != address(0) && actualSigner == expectedSigner;
    }
}
