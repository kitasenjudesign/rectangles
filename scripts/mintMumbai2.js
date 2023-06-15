const Web3 = require("web3");

// ADDRESS, KEY and URL are examples.
const CONTRACT_ADDRESS = "0x4f63A2c49CE98501a473db138605a77D808373fb";//"0x593b7959C273ac32afDD212833f0E334aF6d3a90"//"0x10DF33530474e0e6F6B8f2f78D57E745A4611c56";

//テスト用ウェレットのpublic key / private key
const PUBLIC_KEY = "0x2F7E3D0069e12686bAB4B66448e1315A51AA2eC0";
const PRIVATE_KEY = "0x67028bccf8ec3b99063451c2af3b58b3e4d55646eee7917878b738991b2eceaa";

//"Alchemyで取得したURL";
const PROVIDER_URL = "https://polygon-mumbai.g.alchemy.com/v2/H5P3RPHfZ-6MQhZUGhpFP1nBijap122M";

async function mintNFT() {
    
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
    data: nftContract.methods.mint(50,10,30,30,16,30).encodeABI()
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
