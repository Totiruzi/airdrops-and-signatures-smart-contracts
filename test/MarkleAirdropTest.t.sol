// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {BagelToken} from "src/BagelToken.sol";
import {MarkleAirdrop} from "src/MarkleAirdrop.sol";
import {ZkSyncChainChecker} from "@foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMarkleAirdrop} from "script/DeployMarkleAirdrop.s.sol";

contract MarkleAidropTest is ZkSyncChainChecker, Test {
    BagelToken token;
    MarkleAirdrop airdrop;
    DeployMarkleAirdrop deployer;

    uint256 public constant AMOUNT_TO_CLAIM = 25e18;
    uint256 public constant AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofOne, proofTwo];
    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    address user;
    uint256 userPrivateKey;

    function setUp() public {
        if (!isZkSyncChain()) {
            // deploy with the script
            deployer = new DeployMarkleAirdrop();
            (airdrop, token) = deployer.deployMarkleAirdrop();
        } else {
            token = new BagelToken();
            airdrop = new MarkleAirdrop(ROOT, token);
            token.mint(token.owner(), AMOUNT_TO_SEND);
            token.transfer(address(airdrop), AMOUNT_TO_SEND);
        }
        (user, userPrivateKey) = makeAddrAndKey("user");
    }

    function testUserCanClaimToken() public {
        uint256 startingBalance = token.balanceOf(user);

        vm.prank(user);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF);

        uint256 endingBalance = token.balanceOf(user);

        console2.log("Ending balance", endingBalance);
        assertEq((endingBalance - startingBalance), AMOUNT_TO_CLAIM);
    }
}
