const Web3 = require("web3");
const web3 = new Web3("http://127.0.0.1:7545"); // Replace with your network details

const contractJson = require("./build/contracts/YourContract.json"); // Replace with your contract name

const abi = contractJson.abi;
const address = contractJson.networks["<Your Network ID>"].address;

const contract = new web3.eth.Contract(abi, address);

async function main() {
  const accounts = await web3.eth.getAccounts();

  // Example: Call a contract function
  const result = await contract.methods.someFunction().call({ from: accounts[0] });
  console.log("Result:", result);

  // Example: Send a transaction to a contract function
  const tx = await contract.methods.someFunction().send({ from: accounts[0] });
  console.log("Transaction:", tx);
}

main();
