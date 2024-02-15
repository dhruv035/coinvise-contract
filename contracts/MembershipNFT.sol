//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";

contract MembershipNFT is ERC721, AccessControlEnumerable {
    uint256 private _nextTokenId;
    string public baseURI;
    uint256 _basePrice;
    bool _switch;
    address private owner;

    bytes32 public constant MEMBER_ROLE = keccak256("MEMBER_ROLE");
    bytes32 public constant CREATOR_ROLE = keccak256("MEMBER_ROLE");
    
    mapping (address=>uint256) balances;
    mapping (address=>uint256) shares;
    constructor(address initialOwner, string memory name, string memory symbol, string memory baseURL, uint256 basePrice, bool switchValue)
        ERC721(name,symbol)
    {
        _basePrice = basePrice;
        _switch = switchValue;
        baseURI = baseURL;
        shares[initialOwner]=1;
        owner = initialOwner;
        _grantRole(DEFAULT_ADMIN_ROLE, initialOwner);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory newURI) public onlyRole(DEFAULT_ADMIN_ROLE){
        baseURI = newURI;
    }


    function currentPrice() public view returns (uint256) {
       if (_switch == false)
       return _basePrice;
       else
       return (_basePrice + (_nextTokenId*0.01 ether));
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControlEnumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    function safeMint(address to) public payable {
        
        require(msg.value>=currentPrice());
        
        uint256 creatorCount = getRoleMemberCount(CREATOR_ROLE);
        uint256 tokenId = _nextTokenId++;
        address creator;
         _grantRole(MEMBER_ROLE, to);
        _safeMint(to, tokenId);
        for(uint256 i = 0; i<creatorCount;i++)
        {
            creator = getRoleMember(CREATOR_ROLE, i);
            balances[creator]+=msg.value * shares[creator];
        }

    }

    function withdraw(uint256 amount) public payable {
        require(balances[msg.sender]>amount,"Not Enough Balance");
       balances[msg.sender]-=amount;
       
    }

    function withdrawExtra() public payable {
        require(msg.sender==owner,"Only owner may call");
        uint256 creatorCount = getRoleMemberCount(CREATOR_ROLE);
        address creator;
        uint256 sum=0;
        for(uint256 i=0;i<creatorCount;i++)
        {
            creator = getRoleMember(CREATOR_ROLE, i);
            sum+=balances[creator];
        }
    }
    receive() external payable {   
    }
    function addCreator(address newCreator, uint256 share) public onlyRole(DEFAULT_ADMIN_ROLE) {
     uint256 creatorCount = getRoleMemberCount(CREATOR_ROLE);
     uint256 temp;
     uint256 sum = 0;
     address creator;
     for (uint256 i = 0;i < creatorCount; i++)
     {
        creator = getRoleMember(CREATOR_ROLE, i);
        temp = share * shares[creator];
        shares[creator]-=temp;
        shares[newCreator]+=temp;
        sum+=shares[creator];
     }
      if(sum>1)
     {
        uint256 temp = sum-1;
        shares[owner]-=temp;
     }
     else if(sum<1)
      {
        uint256 temp = 1-sum;
        shares[owner]+=temp;
     }
    }
    function revokeCreator(address payable revokedCreator, uint256 share) public onlyRole(DEFAULT_ADMIN_ROLE) {
     uint256 creatorCount = getRoleMemberCount(CREATOR_ROLE);
     uint256 grow;
     address creator;
     uint256 sum = 0;
     uint256 clearance;
     shares[revokedCreator]=0;
     for (uint256 i = 0;i < creatorCount; i++)
     {
        creator = getRoleMember(CREATOR_ROLE, i);
        if(creator==revokedCreator)
        continue;
        else{
            grow = share * shares[creator];
            shares[creator]+=grow;
            sum+=shares[creator];
            }
     }
     if(sum>1)
     {
        uint256 temp = sum-1;
        shares[owner]-=temp;
     }
     else if(sum<1)
      {
        uint256 temp = 1-sum;
        shares[owner]+=temp;
     }
     clearance = balances[revokedCreator];
     balances[revokedCreator]=0;
     revokedCreator.transfer(clearance);
    }
}