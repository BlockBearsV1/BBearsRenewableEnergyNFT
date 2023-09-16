// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BBearsRenewableEnergyNFT.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BBearsVREMarketplace is ReentrancyGuard, AccessControlEnumerable {
    using SafeMath for uint256;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    struct Listing {
        address seller;
        uint256 price;
        bool active;
    }

    mapping(uint256 => Listing) private listings;

    BBearsRenewableEnergyNFT private nftContract;
    uint256 public adminFeePercentage;

    constructor(address _nftContractAddress, uint256 _adminFeePercentage) {
        nftContract = BBearsRenewableEnergyNFT(_nftContractAddress);
        adminFeePercentage = _adminFeePercentage;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "BBearsVREMarketplace: must have admin role");
        _;
    }

    function setAdminFeePercentage(uint256 _percentage) external onlyAdmin {
        require(_percentage >= 0 && _percentage <= 100, "BBearsVREMarketplace: invalid percentage");
        adminFeePercentage = _percentage;
    }

    function payTax(uint256 tokenId) external payable nonReentrant {
        Listing storage listing = listings[tokenId];
        require(listing.active, "BBearsVREMarketplace: NFT not listed for sale");

        uint256 adminFee = listing.price.mul(adminFeePercentage).div(100);
        require(msg.value >= listing.price.add(adminFee), "BBearsVREMarketplace: insufficient payment");

        address payable seller = payable(listing.seller);
        seller.transfer(listing.price);
        
        address payable admin = payable(getRoleMember(ADMIN_ROLE, 0));
        admin.transfer(adminFee);

        nftContract.updateOwnership(tokenId, msg.sender);
        
        delete listings[tokenId];
    }

    function buyNFT(uint256 tokenId) external payable nonReentrant {
        Listing storage listing = listings[tokenId];
        require(listing.active, "BBearsVREMarketplace: NFT not listed for sale");
        require(msg.value >= listing.price, "BBearsVREMarketplace: insufficient payment");

        address payable seller = payable(listing.seller);
        seller.transfer(listing.price);

        nftContract.updateOwnership(tokenId, msg.sender);
         
        delete listings[tokenId];
    }

    function listNFTForSale(uint256 tokenId, uint256 price) external {
        require(nftContract.ownerOf(tokenId) == msg.sender, "BBearsVREMarketplace: caller is not the owner of the NFT");
        require(price > 0, "BBearsVREMarketplace: price must be greater than zero");

        listings[tokenId] = Listing({
            seller: msg.sender,
            price: price,
            active: true
        });
    }

    function cancelListing(uint256 tokenId) external {
        require(nftContract.ownerOf(tokenId) == msg.sender, "BBearsVREMarketplace: caller is not the owner of the NFT");

        delete listings[tokenId];
    }

    function getNFTDetails(uint256 tokenId) external view returns (address owner, uint256 price, bool active) {
        Listing storage listing = listings[tokenId];
         
        return (nftContract.ownerOf(tokenId), listing.price, listing.active);
    }

    function getOwnedNFTs(address owner) external view returns (uint256[] memory) {
        uint256[] memory ownedTokens = nftContract.getOwnedTokens(owner);
        uint256[] memory result = new uint256[](ownedTokens.length);
        uint256 count = 0;

        for (uint256 i = 0; i < ownedTokens.length; i++) {
            if (listings[ownedTokens[i]].active) {
                result[count] = ownedTokens[i];
                count++;
            }
        }

        return result;
    }
}
