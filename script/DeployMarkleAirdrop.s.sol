// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {BagelToken} from "src/BagelToken.sol";
import {MarkleAirdrop} from "src/MarkleAirdrop.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DeployMarkleAirdrop is Script {

    BagelToken token;
    MarkleAirdrop airdrop;

    bytes32 private s_markleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private constant AMOUNT_AIRDROP = 25e18;
    uint256 private s_amountToTtransfer = AMOUNT_AIRDROP * 4;


    function run() external returns(MarkleAirdrop, BagelToken) {
        return deployMarkleAirdrop();
    }

    function deployMarkleAirdrop() public returns(MarkleAirdrop, BagelToken){
        vm.startBroadcast();
        token = new BagelToken();
        airdrop = new MarkleAirdrop(s_markleRoot, IERC20(address(token)));
        token.mint(token.owner(), s_amountToTtransfer);
        token.transfer(address(airdrop), s_amountToTtransfer);
        vm.stopBroadcast();

        return (airdrop, token);
    }
}