// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "./MembershipNFT.sol";

contract MembershipFactory {

 address[] public memberships;
event Deploy(address _contractAddress);

  
    function newMembership (address initialOwner, string memory name, string memory symbol, string memory baseUrl, uint256 basePrice, bool switchValue) public {
        MembershipNFT newNFT = new MembershipNFT(initialOwner, name, symbol, baseUrl, basePrice, switchValue);
        emit Deploy(address(newNFT));
    }

    function getAllMemberships () public view returns(address[] memory) {
        return memberships;
    }
}
