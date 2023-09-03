// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BBearsVREMarketplace is ERC721Enumerable, AccessControl {
    using SafeMath for uint256;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant PRODUCER_ROLE = keccak256("PRODUCER_ROLE");

    string public constant _name = "BBearsRenewableEnergyNFT";
    string public constant _symbol = "BBVRE";
    string private _baseTokenURI = "https://nft.b-bears.com/";

    address payable public admin;

    struct RenewableEnergyNFT {
        string energyType;
        uint256 productionDate;
        uint256 carbonEmissions;
        uint256 energyEfficiency;
        uint256 price;
        bool isListed;
    }

    mapping(uint256 => RenewableEnergyNFT) public renewableEnergyNFTs;

    event NFTMintedEvent(
        uint256 indexed tokenId,
        string energyType,
        uint256 productionDate
    );
    event AIPredictionAddedEvent(
        uint256 indexed tokenId,
        uint256 timestamp,
        uint256 predictionValue
    );
    event TaxPaidEvent(address payer, uint256 tokenId, uint256 amount);
    event WithdrawnFromVaultEvent(address user, uint256 amount);
    event NFTListedEvent(uint256 indexed tokenId, uint256 price);
    event NFTPurchasedEvent(
        uint256 indexed tokenId,
        address buyer,
        address seller,
        uint256 price
    );

    struct AIPrediction {
        uint256 tokenId;
        uint256 timestamp;
        uint256 predictionValue;
    }

    mapping(uint256 => AIPrediction) public aiPredictions;
    mapping(address => uint256) public vaultBalances;

    constructor(string memory baseURI) ERC721(_name, _symbol) {
        _baseTokenURI = baseURI;
        admin = payable(msg.sender); // Set the admin to the contract deployer
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(PRODUCER_ROLE, msg.sender);
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Not authorized as admin");
        _;
    }

    modifier onlyProducer() {
        require(
            hasRole(PRODUCER_ROLE, msg.sender),
            "Not authorized as producer"
        );
        _;
    }

    /**
     * @dev Mint a new NFT.
     */
    function mintNFT(
        address to,
        string memory energyType,
        uint256 productionDate,
        uint256 carbonEmissions,
        uint256 energyEfficiency,
        uint256 tokenId
    ) external onlyProducer {
        require(!_exists(tokenId), "Token ID already exists");
        renewableEnergyNFTs[tokenId] = RenewableEnergyNFT(
            energyType,
            productionDate,
            carbonEmissions,
            energyEfficiency,
            0,
            false
        );
        _safeMint(to, tokenId);
        emit NFTMintedEvent(tokenId, energyType, productionDate);
    }

    /**
     * @dev Add an AI prediction for a specific token.
     */
    function addAIPrediction(
        uint256 tokenId,
        uint256 timestamp,
        uint256 predictionValue
    ) external onlyAdmin {
        require(_exists(tokenId), "Token ID does not exist");
        aiPredictions[tokenId] = AIPrediction(
            tokenId,
            timestamp,
            predictionValue
        );
        emit AIPredictionAddedEvent(tokenId, timestamp, predictionValue);
    }

    /**
     * @dev Pay taxes for a specific token.
     */
    function payTax(uint256 tokenId, uint256 amount) external payable {
        require(_exists(tokenId), "Token ID does not exist");
        address payer = msg.sender;
        // Add tax payment logic here
        emit TaxPaidEvent(payer, tokenId, amount);
    }

    /**
     * @dev Deposit ETH to the vault.
     */
    function depositToVault() external payable {
        vaultBalances[msg.sender] = vaultBalances[msg.sender].add(msg.value);
    }

    /**
     * @dev Withdraw ETH from the vault.
     */
    function withdrawFromVault(uint256 amount) external {
        require(vaultBalances[msg.sender] >= amount, "Insufficient funds in the vault");
        vaultBalances[msg.sender] = vaultBalances[msg.sender].sub(amount);
        payable(msg.sender).transfer(amount);
        emit WithdrawnFromVaultEvent(msg.sender, amount);
    }

    /**
     * @dev Set the base URI for token metadata.
     */
    function setBaseURI(string memory baseURI) external onlyAdmin {
        require(bytes(baseURI).length > 0, "Base URI must not be empty");
        _baseTokenURI = baseURI;
    }

    /**
     * @dev List an NFT for sale.
     */
    function listNFTForSale(uint256 tokenId, uint256 price)
        external
        onlyProducer
    {
        require(ownerOf(tokenId) == msg.sender, "Only the owner can list the NFT for sale");
        require(!renewableEnergyNFTs[tokenId].isListed, "NFT is already listed for sale");
        renewableEnergyNFTs[tokenId].isListed = true;
        renewableEnergyNFTs[tokenId].price = price;
        emit NFTListedEvent(tokenId, price);
    }

    /**
     * @dev Purchase an NFT.
     */
    function purchaseNFT(uint256 tokenId) external payable {
        require(renewableEnergyNFTs[tokenId].isListed, "NFT is not listed for sale");
        require(msg.value >= renewableEnergyNFTs[tokenId].price, "Insufficient payment");
        address seller = ownerOf(tokenId);
        address buyer = msg.sender;
        uint256 price = renewableEnergyNFTs[tokenId].price;
        // Calculate the 0.7% transaction fee for the admin
        uint256 adminFee = (price * 7) / 1000; // 0.7% fee
        // Transfer ownership
        transferFrom(seller, buyer, tokenId);
        // Update NFT status
        renewableEnergyNFTs[tokenId].isListed = false;
        renewableEnergyNFTs[tokenId].price = 0;
        // Transfer payment to seller minus admin fee
        uint256 sellerAmount = price - adminFee;
        payable(seller).transfer(sellerAmount);
        // Transfer admin fee to the admin
        admin.transfer(adminFee);
        emit NFTPurchasedEvent(tokenId, buyer, seller, price);
    }

    /**
     * @dev Implementation of IERC165.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
