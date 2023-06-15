const Web3 = require("web3");

const web3 = new Web3('http://localhost:8545');
const hoge = require("./Rectangles.json");
const contractABI = hoge.abi;
const contractAddress = '0x5FC8d32690cc91D4c39d9d3abcBD16989F875707';
const contract = new web3.eth.Contract(contractABI, contractAddress);

// Get accounts
web3.eth.getAccounts().then(async (accounts) => {
    // Call a function from your contract
    console.log(accounts.length)
    console.log(accounts[0])
    //console.log(contract.mint)
    
    //const result = await contract.methods.mint(23,4,99,10,47,20).call({from: accounts[0]});

    //const txMint3 = await contract.connect(accounts[2]).mint(23,4,99,10,47,20);
    //const txReceipt3 = await txMint.wait(); 

    //console.log(result);
    console.log(await contract.methods.totalSupply().call());
});



     
    
    //console.log(await rectangles.getCreators(0,3));
    //console.log(await rectangles.getTokens(0,2));


