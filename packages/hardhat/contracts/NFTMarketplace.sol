// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is ERC721Enumerable, Ownable {
    using Address for address payable;

    struct NFT {
        address owner;
        uint256 price;
    }

    mapping(uint256 => NFT) public nfts;

    event NFTListed(uint256 tokenId, uint256 price);
    event NFTSold(uint256 tokenId, address buyer, uint256 price);

    constructor() ERC721("NFTMarketplace", "NFTM") {}

    function listNFT(uint256 tokenId, uint256 price) public {
        require(_exists(tokenId), "Token ID does not exist");
        require(ownerOf(tokenId) == msg.sender, "You are not the owner");
        nfts[tokenId] = NFT(msg.sender, price);
        emit NFTListed(tokenId, price);
    }

    function buyNFT(uint256 tokenId) public payable {
        require(_exists(tokenId), "Token ID does not exist");
        NFT memory nft = nfts[tokenId];
        require(nft.owner != address(0), "NFT not listed for sale");
        require(msg.value >= nft.price, "Insufficient funds");

        address payable owner = payable(nft.owner);
        owner.transfer(msg.value);

        _transfer(nft.owner, msg.sender, tokenId);
        delete nfts[tokenId];

        emit NFTSold(tokenId, msg.sender, msg.value);
    }

    function withdrawBalance() public onlyOwner {
        address payable owner = payable(owner());
        owner.transfer(address(this).balance);
    }
}