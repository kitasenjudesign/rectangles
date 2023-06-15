const Web3 = require("web3");

const web3 = new Web3('http://localhost:8545');
const hoge = require("../artifacts/contracts/Rectangles.sol/Rectangles.json");
const contractABI = hoge.abi;
const contractAddress = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
const contract = new web3.eth.Contract(contractABI, contractAddress);

// Get accounts
web3.eth.getAccounts().then(async (accounts) => {
    // Call a function from your contract
    console.log(accounts.length)
    console.log(accounts[0])
    
    const result = await contract.methods.mint(23,4,99,10,47,20).call({from: accounts[0]});
    console.log(result);
    console.log(await contract.methods.totalSupply().call());
});