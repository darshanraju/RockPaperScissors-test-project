const { expect } = require("chai");

describe("RockPaperScissors contract", function () {
  it("Successfuly deploys contract", async function () {
    const [owner] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Token");

    const hardhatToken = await Token.deploy();

    const ownerBalance = await hardhatToken.balanceOf(owner.address);
    expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  });

  it("Can pay to enter next round", async () => {})

  it("Cannot pay twice to enter next round", async () => {})

  it("Cannot send inssufficient funds to enter next round", async () => {})

  it("Cannot have more than 2 players waiting for the next round", async () => {})

  it("Can select a move after paying", async () => {})

  it("Recieve all funds after winning a round", async () => {}

});