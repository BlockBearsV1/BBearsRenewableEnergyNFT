// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BBearsVREMarketplace is ERC721Enumerable, AccessControl {
    using SafeMath for uint256;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant PRODUCER_ROLE = keccak256("PRODUCER_ROLE");

    string private _name = "BBearsVREMarketplace";
    string private _symbol = "BBVRE";
    string private _baseTokenURI;

    struct RenewableEnergyNFT {
        string energyType;
        uint256 productionDate;
        uint256 carbonEmissions;
        uint256 energyEfficiency;
        uint256 price;
        bool isListed;
    }

    RenewableEnergyNFT[] public renewableEnergyNFTs;

    event NFTMinted(uint256 indexed tokenId, string energyType, uint256 productionDate);
    event AIPredictionAdded(uint256 indexed tokenId, uint256 timestamp, uint256 predictionValue);
    event TaxPaid(address payer, uint256 tokenId, uint256 amount);
    event WithdrawnFromVault(address user, uint256 amount);
    event NFTListed(uint256 indexed tokenId, uint256 price);
    event NFTPurchased(uint256 indexed tokenId, address buyer, address seller, uint256 price);

    struct AIPrediction {
        uint256 tokenId;
        uint256 timestamp;
        uint256 predictionValue;
    }

    AIPrediction[] public aiPredictions;

    mapping(address => uint128) public vaultBalances;

    constructor() ERC721(_name, _symbol) {
        _baseTokenURI = "";
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(PRODUCER_ROLE, msg.sender);
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Only admins can call this function");
        _;
    }

    modifier onlyProducer() {
        require(hasRole(PRODUCER_ROLE, msg.sender), "Only producers can call this function");
        _;
    }

    // Rest of your contract functions...
    
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) external onlyAdmin {
        _baseTokenURI = baseURI;
    }

    function listNFTForSale(uint256 tokenId, uint256 price) external onlyProducer {
        require(_exists(tokenId), "Token ID does not exist");
        require(ownerOf(tokenId) == msg.sender, "Only the owner can list the NFT for sale");
        renewableEnergyNFTs[tokenId].isListed = true;
        renewableEnergyNFTs[tokenId].price = price;
        emit NFTListed(tokenId, price);
    }

    function purchaseNFT(uint256 tokenId) external payable {
        require(_exists(tokenId), "Token ID does not exist");
        require(renewableEnergyNFTs[tokenId].isListed, "NFT is not listed for sale");
        require(msg.value >= renewableEnergyNFTs[tokenId].price, "Insufficient payment");

        address seller = ownerOf(tokenId);
        address buyer = msg.sender;
        uint256 price = renewableEnergyNFTs[tokenId].price;

        // Transfer ownership
        _transfer(seller, buyer, tokenId);

        // Update NFT status
        renewableEnergyNFTs[tokenId].isListed = false;
        renewableEnergyNFTs[tokenId].price = 0;

        // Transfer payment to seller
        payable(seller).transfer(price);

        emit NFTPurchased(tokenId, buyer, seller, price);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
