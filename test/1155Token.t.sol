// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdJson} from "../lib/forge-std/src/Test.sol";

import {MyToken} from "../src/1155Token.sol";

contract TokenTest is Test {
    using stdJson for string;

    MyToken public myToken;

    struct Result {
        bytes32 leaf;
        bytes32[] proof;
    }

    struct User {
        address user;
        uint256 amount;
        uint256 tokenId;
    }

    Result public result;
    User public user;
    bytes32 root = 0x46783a75d58d65aa0fdc1fee242c0baddc75ffc801d7b6083c93774710ab0edc;
    address user1 = 0xB07C11Fd18fF263A4859c10b3c2D26565d74C9eB;

    function setUp() public {
        myToken = new MyToken(root);
        string memory _root = vm.projectRoot();
        string memory path = string.concat(_root, "/merkle_tree.json");

        string memory json = vm.readFile(path);
        string memory data = string.concat(_root, "/address_data.json");

        string memory dataJson = vm.readFile(data);

        bytes memory encodedResult = json.parseRaw(string.concat(".", vm.toString(user1)));
        user.user = vm.parseJsonAddress(dataJson, string.concat(".", vm.toString(user1), ".address"));
        user.amount = vm.parseJsonUint(dataJson, string.concat(".", vm.toString(user1), ".amount"));
        user.tokenId = vm.parseJsonUint(dataJson, string.concat(".", vm.toString(user1), ".tokenId"));
        result = abi.decode(encodedResult, (Result));
        console2.logBytes32(result.leaf);
    }

    function testClaimed() public {
        bool success = myToken.claim(user.user, user.tokenId, user.amount, result.proof);
        assertTrue(success);
    }

    function testAlreadyClaimed() public {
        myToken.claim(user.user, user.tokenId, user.amount, result.proof);
        vm.expectRevert("already claimed");
        myToken.claim(user.user, user.tokenId, user.amount, result.proof);
    }

    function testIncorrectProof() public {
        bytes32[] memory fakeProofleaveitleaveit;

        vm.expectRevert("not whitelisted");
        myToken.claim(user.user, user.tokenId, user.amount, fakeProofleaveitleaveit);
    }
}
