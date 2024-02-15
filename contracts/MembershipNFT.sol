//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";

contract MembershipNFT is ERC721, AccessControlEnumerable {
    struct Collection {
        string collectionId;
        uint256 index;
        address authorizer;
    }

    uint256 private _nextTokenId;
    string public baseURI;
    uint256 public _basePrice;
    uint256 public collectionLength = 0;
    bool public _switch;
    address public owner;

    bytes32 public constant MEMBER_ROLE = keccak256("MEMBER_ROLE");
    bytes32 public constant CREATOR_ROLE = keccak256("MEMBER_ROLE");

    mapping(address => uint256) public balances;
    mapping(address => uint256) public shares;
    mapping(string=>Collection) public idToCollection;
    mapping(uint256=>string) public collections;

    constructor(
        address initialOwner,
        string memory name,
        string memory symbol,
        string memory baseURL,
        uint256 basePrice,
        bool switchValue
    ) ERC721(name, symbol) {
        _basePrice = basePrice;
        _switch = switchValue;
        baseURI = baseURL;
        shares[initialOwner] = uint256(10000);
        owner = initialOwner;
        _grantRole(CREATOR_ROLE, initialOwner);
        _grantRole(DEFAULT_ADMIN_ROLE, initialOwner);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function getCollections() public view returns (string[] memory) {
       string[] memory allCollections = new string[](collectionLength);
       for(uint256 i=1;i<collectionLength;i++)
       allCollections[i-1]=collections[i];
        return allCollections;
    }
    function setBaseURI(string memory newURI)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        baseURI = newURI;
    }

    function addCollection(string memory collectionId) public onlyRole(CREATOR_ROLE) {
       require(idToCollection[collectionId].index==0,"Collection already exists");
       collectionLength++;
       Collection memory newCollection = Collection(collectionId,collectionLength,msg.sender);
       collections[collectionLength]=collectionId;
       idToCollection[collectionId]=newCollection;
    }

    function removeCollection(string memory collectionId) public onlyRole(CREATOR_ROLE) {
       require(idToCollection[collectionId].index!=0,"Collection doesn't exist");

       //Remove Element from its position, replace with the top element, and shorten length
       uint256 index = idToCollection[collectionId].index;                                         
       collections[index]=collections[collectionLength];
       collections[collectionLength]="";
       idToCollection[collections[index]].index=index;
       collectionLength--;
       
    }
    function currentPrice() public view returns (uint256) {
        if (_switch == false) return _basePrice;
        else return (_basePrice + (_nextTokenId * 0.01 ether));
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, AccessControlEnumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function safeMint(address to) public payable {
        require(msg.value >= currentPrice());

        uint256 creatorCount = getRoleMemberCount(CREATOR_ROLE);
        uint256 tokenId = _nextTokenId++;
        address creator;
        _grantRole(MEMBER_ROLE, to);
        _safeMint(to, tokenId);
        for (uint256 i = 0; i < creatorCount; i++) {
            creator = getRoleMember(CREATOR_ROLE, i);
            balances[creator] += msg.value * shares[creator];
        }
    }

    function withdraw(uint256 amount) public payable {
        require(balances[msg.sender] > amount, "Not Enough Balance");
        balances[msg.sender] -= amount;
    }

    function withdrawExtra() public payable {
        require(msg.sender == owner, "Only owner may call");
        uint256 creatorCount = getRoleMemberCount(CREATOR_ROLE);
        address creator;
        uint256 sum = 0;
        for (uint256 i = 0; i < creatorCount; i++) {
            creator = getRoleMember(CREATOR_ROLE, i);
            sum += balances[creator];
        }
    }

    receive() external payable {}

    function addCreator(address newCreator, uint256 share)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        uint256 creatorCount = getRoleMemberCount(CREATOR_ROLE);
        bool isCreator = hasRole(CREATOR_ROLE, newCreator);
        require(!isCreator, "Already a creator, increase share instead");
        uint256 temp;
        uint256 sum = 0;
        address creator;
        for (uint256 i = 0; i < creatorCount; i++) {
            creator = getRoleMember(CREATOR_ROLE, i);
            temp = (share * shares[creator]) / 10000;
            shares[creator] -= temp;
            shares[newCreator] += temp;
             sum += shares[creator];
        }
        sum+=shares[newCreator];
        if (sum > 10000) {
            temp = sum - 10000;
            shares[owner] -= temp;
        } else if (sum < 100) {
            temp = 10000 - sum;
            shares[owner] += temp;
        }
        _grantRole(CREATOR_ROLE, newCreator);
    }

    function revokeCreator(address payable revokedCreator) public {
        bool isAdmin = hasRole(DEFAULT_ADMIN_ROLE, msg.sender);
        if (!isAdmin) {
            require(msg.sender == revokedCreator, "Unauthorized Revoke");
        }
        uint256 creatorCount = getRoleMemberCount(CREATOR_ROLE);
        bool isCreator = hasRole(CREATOR_ROLE, revokedCreator);
        require(!isCreator, "Not a creator");
        uint256 share = shares[revokedCreator];
        uint256 grow;
        address creator;
        uint256 sum = 0;
        uint256 clearance;
        shares[revokedCreator] = uint256(0);
        for (uint256 i = 0; i < creatorCount; i++) {
            creator = getRoleMember(CREATOR_ROLE, i);
            if (creator == revokedCreator) continue;
            else {
                grow = (share * shares[creator]) / (10000 - share);
                shares[creator] += grow;
                sum += shares[creator];
            }
        }
        if (sum > 10000) {
            uint256 temp = sum - 10000;
            shares[owner] -= temp;
        } else if (sum < 10000) {
            uint256 temp = 10000 - sum;
            shares[owner] += temp;
        }
        clearance = balances[revokedCreator];
        balances[revokedCreator] = uint256(0);
        shares[revokedCreator]=uint256(0);
        revokedCreator.transfer(clearance);
    }
}
