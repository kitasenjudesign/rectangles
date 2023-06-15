const Web3 = require("web3");

// ADDRESS, KEY and URL are examples.
const CONTRACT_ADDRESS = "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707";//"0x593b7959C273ac32afDD212833f0E334aF6d3a90"//"0x10DF33530474e0e6F6B8f2f78D57E745A4611c56";

//テスト用ウェレット／ユーザーのpublic key / private key

let PUBLIC_KEY = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
const PRIVATE_KEY = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

//"localhostURL";
const PROVIDER_URL = "http://localhost:8545";





async function mintNFT() {
    
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
  const nonce = await web3.eth.getTransactionCount(PUBLIC_KEY, "latest");


  const tx = {
    from: PUBLIC_KEY,
    to: CONTRACT_ADDRESS,
    nonce: nonce,
    gas: 500000,//ガスの値は任意、適切な値じゃないと余ったり、足りなくてうまくいかなかったりらしい
    data: nftContract.methods.mint(10,Math.floor(10+50*Math.random()),30,30,16,30).encodeABI()
  };

  //署名する
  const signPromise = web3.eth.accounts.signTransaction(tx, PRIVATE_KEY);


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

mintNFT();
