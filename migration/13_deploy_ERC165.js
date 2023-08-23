const ERC165 = artifacts.require("ERC165");

module.exports = function (deployer) {
  deployer.deploy(ERC165);
};