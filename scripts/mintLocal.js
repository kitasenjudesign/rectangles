const Web3 = require("web3");


/*
Account #0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

Account #1: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (10000 ETH)
Private Key: 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d

Account #2: 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC (10000 ETH)
Private Key: 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a
*/

// ADDRESS, KEY and URL are examples.
const CONTRACT_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";//"0x593b7959C273ac32afDD212833f0E334aF6d3a90"//"0x10DF33530474e0e6F6B8f2f78D57E745A4611c56";

//テスト用ウェレット／ユーザーのpublic key / private key
const PUBLIC_KEYS = [
  "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
  "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
  "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"  
];
const PRIVATE_KEYS = [
  "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",
  "0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d",
  "0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a"
];

//"localhostURL";
const PROVIDER_URL = "http://localhost:8545";





async function mintNFT(idx) {
    
  //const [deployer, user1, user2] = await ethers.getSigners();
  //console.log(deployer);

  //イーサネットのネットワークに接続する
  const web3 = new Web3(PROVIDER_URL);
  
  //abi情報を取得
  const contract = require("../artifacts/contracts/Rectangles.sol/Rectangles.json");
  
  //CONTRACTのADDRESSとabi情報を指定してコントラクトのインスタンスを作る
  const nftContract = new web3.eth.Contract(contract.abi, CONTRACT_ADDRESS);

  //このコードは、指定された公開鍵（PUBLIC_KEY）に関連付けられた
  //アドレスのトランザクションカウント（nonce）を取得しています。idみたいなもの？？
  const nonce = await web3.eth.getTransactionCount(PUBLIC_KEYS[idx], "latest");

  let colStr="";
  colStr = ""+Math.floor(Math.random()*8)
  colStr += ""+Math.floor(Math.random()*8)

  const tx = {
    from: PUBLIC_KEYS[idx],
    to: CONTRACT_ADDRESS,
    //const oneEther = ethers.utils.parseEther("0.1");
    value: ethers.utils.parseEther("0.1"),

    nonce: nonce,
    gas: 500000,//ガスの値は任意、適切な値じゃないと余ったり、足りなくてうまくいかなかったりらしい
    data: nftContract.methods.mint(
      Math.floor(10+50*Math.random()),//x
      Math.floor(10+50*Math.random()),//y
      Math.floor(10+30*Math.random()),//w
      Math.floor(10+30*Math.random()),//h
      parseInt(colStr),
      Math.floor(10+190*Math.random())
    ).encodeABI()
  };

  //署名する
  const signPromise = web3.eth.accounts.signTransaction(tx, PRIVATE_KEYS[idx]);


  signPromise
    .then((signedTx) => {
      const tx = signedTx.rawTransaction;
      if (tx !== undefined) {
        //署名したトランザクションを送信する
        web3.eth.sendSignedTransaction(tx, function (err, hash) {
          if (!err) {
            console.log("The hash of your transaction is: ", hash);
          } else {
            console.log(
              "Something went wrong when submitting your transaction:",
              err
            );
          }
        });
      }
    })
    .catch((err) => {
      console.log("Promise failed:", err);
    });
}


mintNFT(0);
mintNFT(1);
mintNFT(2);
