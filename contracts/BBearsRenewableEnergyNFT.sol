// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract RenewableEnergyNFT is ERC721, ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;

    struct EnergyNFT {
        bytes32 energyType;
        uint256 productionDate;
        uint256 carbonEmissions;
        uint256 energyEfficiency;
        uint256 price;
        bool isListed;
        uint256 royaltyFee;
        bytes32 location;
        bytes32 capacity;
        bytes32 certification;
    }

    mapping(uint256 => EnergyNFT) private energyNFTs;
    mapping(uint256 => string) private tokenURIs;
    mapping(uint256 => uint256) private biddingEndTimes;
    mapping(uint256 => uint256) private highestBids;
    mapping(uint256 => address) private highestBidders;

    event RoyaltyFeeSet(uint256 indexed tokenId, uint256 royaltyFee);
    event RoyaltyFeeReceived(uint256 indexed tokenId, address indexed receiver, uint256 amount);
    event BidPlaced(uint256 indexed tokenId, address indexed bidder, uint256 amount);
    event AuctionEnded(uint256 indexed tokenId, address indexed winner, uint256 amount);

    constructor() ERC721("RenewableEnergyNFT", "RENFT") {}

    function mintNFT(
        address to,
        bytes32 energyType,
        uint256 productionDate,
        uint256 carbonEmissions,
        uint256 energyEfficiency,
        uint256 price,
        bytes32 location,
        bytes32 capacity,
        bytes32 certification
    ) external onlyOwner {
        uint256 tokenId = totalSupply();
        energyNFTs[tokenId] = EnergyNFT(
            energyType,
            productionDate,
            carbonEmissions,
            energyEfficiency,
            price,
            false,
            0,
            location,
            capacity,
            certification
        );
        _safeMint(to, tokenId);
    }

    function listNFTForSale(uint256 tokenId, uint256 price) external onlyOwner {
        require(tokenId < totalSupply(), "Token ID does not exist");
        require(!energyNFTs[tokenId].isListed, "NFT is already listed for sale");
        energyNFTs[tokenId].isListed = true;
        energyNFTs[tokenId].price = price;
    }

    function purchaseNFT(uint256 tokenId) external payable {
        require(tokenId < totalSupply(), "Token ID does not exist");
        require(energyNFTs[tokenId].isListed, "NFT is not listed for sale");
        require(msg.value >= energyNFTs[tokenId].price, "Insufficient payment");

        address seller = ownerOf(tokenId);
        address buyer = msg.sender;
        uint256 price = energyNFTs[tokenId].price;
        uint256 royaltyFee = energyNFTs[tokenId].royaltyFee;

        energyNFTs[tokenId].isListed = false;
        energyNFTs[tokenId].price = 0;
        _transfer(seller, buyer, tokenId);

        payable(seller).transfer(price);

        if (royaltyFee > 0) {
            address royaltyReceiver = owner();
            uint256 royaltyAmount = price.mul(royaltyFee).div(10000);
            payable(royaltyReceiver).transfer(royaltyAmount);
            emit RoyaltyFeeReceived(tokenId, royaltyReceiver, royaltyAmount);
        }
    }

    function setRoyaltyFee(uint256 tokenId, uint256 royaltyFee) external onlyOwner {
        require(tokenId < totalSupply(), "Token ID does not exist");
        energyNFTs[tokenId].royaltyFee = royaltyFee;
        emit RoyaltyFeeSet(tokenId, royaltyFee);
    }

    function updateTokenURI(uint256 tokenId, string memory newTokenURI) external onlyOwner {
        require(tokenId < totalSupply(), "Token ID does not exist");
        _setTokenURI(tokenId, newTokenURI);
        tokenURIs[tokenId] = newTokenURI;
    }

    function setBiddingEndTime(uint256 tokenId, uint256 endTime) external onlyOwner {
        require(tokenId < totalSupply(), "Token ID does not exist");
        biddingEndTimes[tokenId] = endTime;
    }

    function placeBid(uint256 tokenId) external payable {
        require(tokenId < totalSupply(), "Token ID does not exist");
        require(biddingEndTimes[tokenId] > block.timestamp, "Bidding has ended");
        require(msg.value > highestBids[tokenId], "Bid amount must be higher than current highest bid");

        if (highestBids[tokenId] > 0) {
            // Refund the previous highest bidder
            address payable previousBidder = payable(highestBidders[tokenId]);
            previousBidder.transfer(highestBids[tokenId]);
        }

        highestBids[tokenId] = msg.value;
        highestBidders[tokenId] = msg.sender;

        emit BidPlaced(tokenId, msg.sender, msg.value);
    }

    function endAuction(uint256 tokenId) external onlyOwner {
        require(tokenId < totalSupply(), "Token ID does not exist");
        require(biddingEndTimes[tokenId] <= block.timestamp, "Bidding has not ended yet");

        address winner = highestBidders[tokenId];
        uint256 amount = highestBids[tokenId];

        highestBids[tokenId] = 0;
        highestBidders[tokenId] = address(0);

        _transfer(owner(), winner, tokenId);
        payable(owner()).transfer(amount);

        emit AuctionEnded(tokenId, winner, amount);
    }

    function getEnergyNFT(uint256 tokenId) external view returns (EnergyNFT memory) {
        require(tokenId < totalSupply(), "Token ID does not exist");
        return energyNFTs[tokenId];
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://nft.b-bears.com/";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(tokenId < totalSupply(), "Token ID does not exist");
        string memory baseURI = _baseURI();
        string memory uri = tokenURIs[tokenId];
        return bytes(uri).length > 0 ? string(abi.encodePacked(baseURI, uri)) : baseURI;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
