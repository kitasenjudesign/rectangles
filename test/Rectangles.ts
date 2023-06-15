import { expect } from "chai";
import { ethers } from "hardhat";

describe("test1", function () {
  it("should success", async function () {

    console.log("hoge");

    const [deployer, user1, user2] = await ethers.getSigners();
    const Rectangles = await ethers.getContractFactory("Rectangles");
    const rectangles = await Rectangles.deploy();
    await rectangles.deployed();

    const oneEther = ethers.utils.parseEther("0.1");
    //value: oneEther

    const txMint = await rectangles.connect(user1).mint(11,22,5,44,62,100, { value: oneEther });
    const txReceipt = await txMint.wait();
    //console.log(await rectangles.tokenURI(0));

    const txMint2 = await rectangles.connect(user2).mint(33,11,22,99,41,60, { value: oneEther });
    const txReceipt2 = await txMint.wait();  
    //console.log(await rectangles.tokenURI(1));

    const txMint3 = await rectangles.connect(deployer).mint(23,4,99,10,47,20, { value: oneEther });
    const txReceipt3 = await txMint.wait();
    
    console.log(await rectangles.getCreators(0,3));
    console.log(await rectangles.getTokens(0,2));
    console.log(await rectangles.tokenURI(0));

    expect(await txReceipt.status).to.equal(1);
  })
})