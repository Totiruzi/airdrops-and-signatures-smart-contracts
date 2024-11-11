// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MarkleAirdrop {
    using SafeERC20 for IERC20;

    /**
     * ERRORS
     */
    error MarkleAirdrop__InvalidProof();
    error MarkleAirdrop__HasAlreadyClaimed();

    address[] claimers;
    bytes32 private immutable i_markleRoot;
    IERC20 private immutable i_airdropToken;

    mapping(address claimer => bool claimed) s_hasClaimed;


    /**
     * EVENTS
     */
    event  Claim(address account, uint256 amount);

    constructor(bytes32 markleRoot, IERC20 airdropToken) {
        i_markleRoot = markleRoot;
        i_airdropToken = airdropToken;
    }

    /**
     *
     * @param accountThatWantsToClaim The account that wants to claim the airdrop
     * @param amountToClaim The amount of airdrop to claim
     * @param markleProof where the ashes of claimers will be stored
     */
    function claim(address accountThatWantsToClaim, uint256 amountToClaim, bytes32[] calldata markleProof) external {
        if(s_hasClaimed[accountThatWantsToClaim]) revert MarkleAirdrop__HasAlreadyClaimed();

        //calculate using account and amount to hash -> leaf node
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(accountThatWantsToClaim, amountToClaim))));

        if (!MerkleProof.verify(markleProof, i_markleRoot, leaf)) revert MarkleAirdrop__InvalidProof();

        s_hasClaimed[accountThatWantsToClaim] = true;
        
        emit Claim(accountThatWantsToClaim, amountToClaim);
        i_airdropToken.safeTransfer(accountThatWantsToClaim, amountToClaim);
    }
}
