require('dotenv').config();
const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545, // Change this to 8545 if you're using Ganache on port 8545
      network_id: "*",
    },
    bsc_mainnet: {
      provider: () => new HDWalletProvider(process.env.MNEMONIC, `https://bsc-dataseed1.binance.org`),
      network_id: 56, // Binance Smart Chain Mainnet
      gas: 2000000, // Adjust the gas value as needed
      gasPrice: 20000000000, // 20 Gwei (in wei)
    },
    bsc_testnet: {
      provider: () => new HDWalletProvider(process.env.MNEMONIC, `https://data-seed-prebsc-1-s1.binance.org:8545`),
      network_id: 97, // Binance Smart Chain Testnet
      gas: 2000000, // Adjust the gas value as needed
      gasPrice: 20000000000, // 20 Gwei (in wei)
    },
  },
  compilers: {
    solc: {
      version: "0.8.21",
    },
  },
};
