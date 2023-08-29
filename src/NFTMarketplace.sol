// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin-contracts/contracts/utils/Counters.sol";
import "./ReentrancyGuard.sol";

contract Marketplace is ERC721, ERC721URIStorage, ReentrancyGuard,IERC721Receiver  {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenId;
    Counters.Counter private _itemsSold;

    uint256 public listingPrice = 0.0025 ether;

    address public owner;

    struct MarketItem{
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool listedForSale;
        bool sold;
    }

    
    mapping(uint256 => MarketItem) public idToMarketItem;
    mapping (uint256=> address) public ownerOfItem;

    constructor() ERC721("NFT MarketPlace", "NMP") {
        owner = payable (msg.sender);
    }

    modifier onlyOwner(){
        require(msg.sender==owner,"Only owner can do this");
        _;
    }
    
    function onERC721Received(address, address, uint256, bytes memory) public virtual override  returns (bytes4) {
        return this.onERC721Received.selector;
    }



    function updateListingPrice(uint256 _listingPrice) public onlyOwner{
        listingPrice = _listingPrice;
    }

    function createNft(uint256 price, string memory uri) public payable returns(uint256) {
        _tokenId.increment();

        uint256 newTokenId = _tokenId.current();
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, uri);

        createMarketItem(newTokenId, price);
        return newTokenId;

    }

    function createMarketItem(uint256 tokenId, uint256 price) private{
        require(price > 0 , "Price must be greater than 0");
        require(msg.value>= listingPrice,"Send the listing price");
        ownerOfItem[tokenId] = msg.sender;
        idToMarketItem[tokenId] = MarketItem(tokenId, payable(msg.sender), payable (address(this)), price,true, false);
        safeTransferFrom(msg.sender, address(this), tokenId);
    }

    function buyItem(uint256 tokenId) public payable nonReentrant {
        require(idToMarketItem[tokenId].listedForSale== true,"Seller don't selling now");
        require(msg.value >= idToMarketItem[tokenId].price,"Send the right the price");
        idToMarketItem[tokenId] = MarketItem(tokenId, payable(msg.sender), payable (msg.sender), 0,false, true);
        ownerOfItem[tokenId] = msg.sender;
        (bool sent,) = idToMarketItem[tokenId].seller.call{value: msg.value}("");
        require(sent,"Cannot send the amount");
        ERC721(address(this)).transferFrom(address(this), msg.sender, tokenId);
        _itemsSold.increment();
    }

    function reSellItem(uint256 tokenId, uint256 price) public payable {
        require(idToMarketItem[tokenId].owner == msg.sender,"Only item owner can resell");
        require(price > 0 , "Price must be greater than 0");
        require(msg.value >= listingPrice,"Send the listing price");
        idToMarketItem[tokenId] = MarketItem(tokenId, payable(msg.sender), payable (address(this)), price,true, false);
        _itemsSold.decrement();
        safeTransferFrom(msg.sender, address(this), tokenId);
    }

    function withdraw() public payable onlyOwner nonReentrant{
        (bool sent,) = payable(address(msg.sender)).call{value:address(this).balance}("");
        require(sent, "Failed to send Ether");
    }


    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
