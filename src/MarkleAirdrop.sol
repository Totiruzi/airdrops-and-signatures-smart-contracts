// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MarkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    /**
     * ERRORS
     */
    error MarkleAirdrop__InvalidProof();
    error MarkleAirdrop__HasAlreadyClaimed();
    error MarkleAirdrop__InvalidSignayure();

    address[] claimers;
    bytes32 private immutable i_markleRoot;
    IERC20 private immutable i_airdropToken;

    mapping(address claimer => bool claimed) s_hasClaimed;

    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    /**
     * EVENTS
     */
    event Claim(address account, uint256 amount);

    constructor(bytes32 markleRoot, IERC20 airdropToken) EIP712("MarkleAirdrop", "1") {
        i_markleRoot = markleRoot;
        i_airdropToken = airdropToken;
    }

    /**
     *
     * @param accountThatWantsToClaim The account that wants to claim the airdrop
     * @param amountToClaim The amount of airdrop to claim
     * @param markleProof where the ashes of claimers will be stored
     */
    function claim(
        address accountThatWantsToClaim,
        uint256 amountToClaim,
        bytes32[] calldata markleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (s_hasClaimed[accountThatWantsToClaim]) revert MarkleAirdrop__HasAlreadyClaimed();

        // verify the signature
        if (!_validSignature(accountThatWantsToClaim, getMessageHash(accountThatWantsToClaim, amountToClaim), v, r, s)) {
            revert MarkleAirdrop__InvalidSignayure();
        }
        //calculate using account and amount to hash -> leaf node
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(accountThatWantsToClaim, amountToClaim))));

        if (!MerkleProof.verify(markleProof, i_markleRoot, leaf)) revert MarkleAirdrop__InvalidProof();

        s_hasClaimed[accountThatWantsToClaim] = true;

        emit Claim(accountThatWantsToClaim, amountToClaim);
        i_airdropToken.safeTransfer(accountThatWantsToClaim, amountToClaim);
    }

    function getMarkleRoot() external view returns (bytes32) {
        return i_markleRoot;
    }

    function getAirgropToken() external view returns (IERC20) {
        return i_airdropToken;
    }

    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return
            _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))));
    }

    function _validSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        (address actualSignature, , ) = ECDSA.tryRecover(digest, v, r, s);
        return actualSignature == account;
    }
}
