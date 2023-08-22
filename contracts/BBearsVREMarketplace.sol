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
    string private _baseTokenURI = "https://nft.b-bears.com/";

    // ... rest of your contract code ...

    // Explicitly override supportsInterface to specify the implementation
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // Keep your vault and tax functions here
    function depositToVault() external payable {
        vaultBalances[msg.sender] += uint128(msg.value);
    }

    function withdrawFromVault(uint256 amount) external {
        require(vaultBalances[msg.sender] >= amount, "Insufficient funds in the vault");
        vaultBalances[msg.sender] -= uint128(amount);
        payable(msg.sender).transfer(amount);
        emit WithdrawnFromVault(msg.sender, amount);
    }

    function payTax(uint256 tokenId, uint256 amount) external {
        require(_exists(tokenId), "Token ID does not exist");
        address payer = msg.sender;
        // Perform tax payment logic
        emit TaxPaid(payer, tokenId, amount);
    }
}
