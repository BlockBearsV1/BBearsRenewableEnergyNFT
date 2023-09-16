// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BBearsRenewableEnergyNFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    struct RenewableEnergyNFT {
        string energyType;
        uint256 productionDate;
        uint256 carbonEmissions;
        uint256 energyEfficiency;
        uint256 price;
        bool isListed;
    }
    
    mapping(uint256 => RenewableEnergyNFT) public nfts;

    constructor() ERC721("BBears Renewable Energy NFT", "BBREN") {}

    function createNFT(
        string memory _energyType,
        uint256 _productionDate,
        uint256 _carbonEmissions,
        uint256 _energyEfficiency,
        uint256 _price
    ) public returns (uint256) {
        require(bytes(_energyType).length > 0, "Energy type must be provided");
        
        // Create a new NFT
        RenewableEnergyNFT memory newNft = RenewableEnergyNFT({
            energyType: _energyType,
            productionDate: _productionDate,
            carbonEmissions: _carbonEmissions,
            energyEfficiency: _energyEfficiency,
            price: _price,
            isListed: false
        });
        
        // Increment token ID
        _tokenIds.increment();
        
        // Get the new token ID
        uint256 newTokenId = _tokenIds.current();
        
        // Mint the NFT to the sender's address
        _mint(msg.sender, newTokenId);
        
        // Store the NFT in the mapping using the token ID as the key
        nfts[newTokenId] = newNft;
        
        // Return the new token ID
        return newTokenId;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return ""; // Return the metadata URI for a given token ID
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Transfer not approved");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Transfer not approved");
        _safeTransfer(from, to, tokenId, "");
    }

    function approve(address approved, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        require(approved != owner, "Already approved");
        
        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "Not authorized"
        );
        
        // Approve an address to manage the specified token ID
        _approve(approved, tokenId);
    }
    
    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "Cannot self-approve");
        
        // Approve or revoke an address as an operator for all tokens owned by the sender
        setApprovalForAll(operator, approved);
    }
}
