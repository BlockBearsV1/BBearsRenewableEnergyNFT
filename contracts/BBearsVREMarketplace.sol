// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BBearsVREMarketplace is ERC721Enumerable, AccessControl {
    using SafeMath for uint256;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant PRODUCER_ROLE = keccak256("PRODUCER_ROLE");

    string private _name = "BBearsVRenewableEnergyNFT"; // Updated collection name
    string private _symbol = "BBVRE";
    string private _baseTokenURI = "https://nft.b-bears.com/"; // Updated base URI

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

    constructor(string memory baseURI) ERC721(_name, _symbol) {
        _baseTokenURI = baseURI;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(PRODUCER_ROLE, msg.sender);
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "BBVRE: Only admins can call this function");
        _;
    }

    modifier onlyProducer() {
        require(hasRole(PRODUCER_ROLE, msg.sender), "BBVRE: Only producers can call this function");
        _;
    }

    function mintNFT(
        address to,
        string memory energyType,
        uint256 productionDate,
        uint256 carbonEmissions,
        uint256 energyEfficiency
    ) external onlyProducer {
        uint256 tokenId = renewableEnergyNFTs.length;
        renewableEnergyNFTs.push(
            RenewableEnergyNFT({
                energyType: energyType,
                productionDate: productionDate,
                carbonEmissions: carbonEmissions,
                energyEfficiency: energyEfficiency,
                price: 0,
                isListed: false
            })
        );
        _safeMint(to, tokenId);
        emit NFTMinted(tokenId, energyType, productionDate);
    }

    function addAIPrediction(uint256 tokenId, uint256 timestamp, uint256 predictionValue) external onlyAdmin {
        require(_exists(tokenId), "BBVRE: Token ID does not exist");
        aiPredictions.push(AIPrediction({ tokenId: tokenId, timestamp: timestamp, predictionValue: predictionValue }));
        emit AIPredictionAdded(tokenId, timestamp, predictionValue);
    }

    function payTax(uint256 tokenId, uint256 amount) external {
        require(_exists(tokenId), "BBVRE: Token ID does not exist");
        address payer = msg.sender;
        // Perform tax payment logic
        emit TaxPaid(payer, tokenId, amount);
    }

    function depositToVault() external payable {
        vaultBalances[msg.sender] += uint128(msg.value);
    }

    function withdrawFromVault(uint256 amount) external {
        require(vaultBalances[msg.sender] >= amount, "BBVRE: Insufficient funds in the vault");
        vaultBalances[msg.sender] -= uint128(amount);
        payable(msg.sender).transfer(amount);
        emit WithdrawnFromVault(msg.sender, amount);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) external onlyAdmin {
        _baseTokenURI = baseURI;
    }

    function listNFTForSale(uint256 tokenId, uint256 price) external onlyProducer {
        require(_exists(tokenId), "BBVRE: Token ID does not exist");
        require(ownerOf(tokenId) == msg.sender, "BBVRE: Only the owner can list the NFT for sale");
        renewableEnergyNFTs[tokenId].isListed = true;
        renewableEnergyNFTs[tokenId].price = price;
        emit NFTListed(tokenId, price);
    }

    function purchaseNFT(uint256 tokenId) external payable {
        require(_exists(tokenId), "BBVRE: Token ID does not exist");
        require(renewableEnergyNFTs[tokenId].isListed, "BBVRE: NFT is not listed for sale");
        require(msg.value >= renewableEnergyNFTs[tokenId].price, "BBVRE: Insufficient payment");

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

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
