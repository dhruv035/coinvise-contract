// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "./MembershipNFT.sol";

contract MembershipFactory {

   address [] public memberships;
    mapping (address=>address[])creators;
    function newMembership (address initialOwner, string memory name, string memory symbol, string memory baseUrl, uint256 basePrice, bool switchValue) public returns (address) {
        MembershipNFT newNFT = new MembershipNFT(initialOwner, name, symbol, baseUrl, basePrice, switchValue);
        memberships.push((address(newNFT)));
        creators[initialOwner].push((address(newNFT)));
        return address(newNFT);
    }

    function getAllMemberships () public view returns(address[] memory) {
        return memberships;
    }
    function getCreatorStack (address creator) public view returns(address[] memory) {
        return creators[creator];
    }
}
