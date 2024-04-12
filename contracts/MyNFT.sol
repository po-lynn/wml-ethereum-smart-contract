// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract MyNFT is Ownable(msg.sender), ERC721URIStorage {
  // Constructor to set the NFT name and symbol
  constructor() ERC721("POLYNN NFT", "PLS") {}

  // Function to mint a new NFT (only owner can call)
  function mint(address recipient, uint256 tokenId, string memory tokenURI) public onlyOwner {
    _mint(recipient, tokenId);
    _setTokenURI(tokenId, tokenURI);
  }
}

