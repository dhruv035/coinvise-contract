pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MembershipNFT is ERC721, Ownable {
    uint256 private _nextTokenId;
    string public baseURI;
    uint256 _basePrice;
    bool _switch;

    
    constructor(address initialOwner, string memory name, string memory symbol, string memory baseURL, uint256 basePrice, bool switchValue)
        ERC721(name,symbol)
        Ownable(initialOwner)
    {
        _basePrice = basePrice;
        _switch = switchValue;
        baseURI = baseURL;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory newURI) public onlyOwner{
        baseURI = newURI;
    }

    function currentPrice() public view returns (uint256) {
       if (_switch == false)
       return _basePrice;
       else
       return (_basePrice + (_nextTokenId*0.01 ether));
    }

    function safeMint(address to) public payable {

        require(msg.value>=currentPrice());
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }
}