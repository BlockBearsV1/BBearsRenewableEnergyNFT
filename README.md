# BBears Renewable Energy Marketplace

Welcome to the BBears Renewable Energy Marketplace project! This decentralized marketplace allows users to mint and trade Renewable Energy NFTs (Non-Fungible Tokens) representing various types of renewable energy sources.

## Getting Started

### Prerequisites

Before you begin, ensure you have met the following requirements:
- [ ] Install Node.js and npm.
- [ ] Install Truffle for local development and testing.
- [ ] Set up a development environment (e.g., Ganache or a testnet).
- [ ] Configure Metamask or another Ethereum wallet.

### Installation

1. Clone the repository:

   ```
   git clone https://github.com/your-username/bbears-renewable-energy-marketplace.git
   cd bbears-renewable-energy-marketplace

1. Install project dependencies:
   Before you can run this project, make sure you have Node.js installed. We recommend using Node.js version 18.17.1 or higher.

![Node.js Version](https://img.shields.io/badge/node-%3E%3D18.17.1-brightgreen.svg)

To install project dependencies, run:

```bash
npm install

 ### Usage
  
1. Compile the smart contracts:
   ```
   truffle compile

2. Migrate the contracts to your development environment:
   ```
   truffle migrate --reset

3. Start the development server:
   ```
   npm run dev

4. Access the marketplace in your web browser at http://localhost:3000.

### Deployment
To deploy the BBears Renewable Energy Marketplace to the Ethereum mainnet or a testnet, follow these steps:

1. Set up an Ethereum wallet and get some Ether for gas.
2. Update the Truffle configuration (truffle-config.js) with your wallet's private key and Ethereum network settings.
3. Deploy the smart contracts:
   ```
   truffle migrate --network <network-name>
4. Update the contract addresses in the frontend and any other necessary configurations.

### Contributing

Contributions are welcome! Feel free to open issues, submit pull requests, or suggest improvements. For major changes, please open an issue first to discuss your ideas.

### License

This project is licensed under the MIT License. See the LICENSE file for details.

