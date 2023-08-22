// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract BBearsVREMarketplace is ERC721Enumerable, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant PRODUCER_ROLE = keccak256("PRODUCER_ROLE");

    string private _name = "BBearsVREMarketplace";
    string private _symbol = "BBVRE";
    string private _baseTokenURI = "https://nft.b-bears.com/";

    struct RenewableEnergyNFT {
        string energyType;
        uint256 productionDate;
        uint256 carbonEmissions;
        uint256 energyEfficiency;
        uint256 price;
        bool isListed;
    }

    RenewableEnergyNFT[] public renewableEnergyNFTs;

    struct AIPrediction {
        uint256 tokenId;
        uint256 timestamp;
        uint256 predictionValue;
    }

    AIPrediction[] public aiPredictions;

    mapping(address => uint128) public vaultBalances;

    constructor() ERC721(_name, _symbol) {
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
    }

    function addAIPrediction(uint256 tokenId, uint256 timestamp, uint256 predictionValue) external onlyAdmin {
        require(_exists(tokenId), "Token ID does not exist");
        aiPredictions.push(AIPrediction({ tokenId: tokenId, timestamp: timestamp, predictionValue: predictionValue }));
    }

    function depositToVault() external payable {
        vaultBalances[msg.sender] += uint128(msg.value);
    }

    function withdrawFromVault(uint256 amount) external {
        require(vaultBalances[msg.sender] >= amount, "Insufficient funds in the vault");
        vaultBalances[msg.sender] -= uint128(amount);
        payable(msg.sender).transfer(amount);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) external onlyAdmin {
        _baseTokenURI = baseURI;
    }
}
