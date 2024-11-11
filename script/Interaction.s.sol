// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "@foundry-devops/src/DevOpsTools.sol";
import {MarkleAirdrop} from "src/MarkleAirdrop.sol";

contract ClaimAirdrop is Script {
    /**
     * ERROR
     */
    error ClaimAirdrop__InvalidSignatue();

    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 public constant CLAIMING_AMOUNT = 25e18;
    bytes32 PROOF_ONE = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 PROOF_TWO = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [PROOF_ONE, PROOF_TWO];
    bytes private SIGNATURE = hex"7b3ddc70514582457d1ce703d9a972d1d3ae6d0656e40542bc3c79ae3478cda97a074c4bdf30f2dcd98cc8b0ebd834562e602dc5a6956a656642362a7fd267b51b";
    
    function  run()  external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MarkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }

    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        MarkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, proof, v, r, s);
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory signature) public pure returns(uint8 v, bytes32 r, bytes32 s) {
        if(signature.length != 65) revert  ClaimAirdrop__InvalidSignatue();

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
    }
}
