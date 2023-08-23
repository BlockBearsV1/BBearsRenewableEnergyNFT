const ERC721Enumerable = artifacts.require("ERC721Enumerable");

module.exports = function (deployer) {
  deployer.deploy(ERC721Enumerable);
};