const { expect } = require("chai");
const { BigNumber } = require("ethers");

describe("RockPaperScissors contract", function () {
  let RockPaperScissorsContract;
  let owner;
  let addr1;
  let addr2;
  let addr3;
  let addrs;

  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    contract = await ethers.getContractFactory("RockPaperScissors");
    [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
    RockPaperScissorsContract = await contract.deploy();
  });

  it("Successfuly deploys contract", async function () {
    expect(await RockPaperScissorsContract.getBalance()).to.equal(0);
  });

  it("Can pay to enter next round", async () => {
    const deposit = 1000;
    await RockPaperScissorsContract.enterNextRound(deposit, {
      value: deposit,
    });
    expect(await RockPaperScissorsContract.getBalance()).to.equal(deposit);
  });

  it("Cannot pay twice to enter next round", async () => {
    const deposit = 1000;
    await RockPaperScissorsContract.enterNextRound(deposit, {
      value: deposit,
    });
    await expect(
      RockPaperScissorsContract.enterNextRound(deposit, {
        value: deposit,
      })
    ).to.be.revertedWith("Already paid");
  });

  it("Cannot send inssufficient funds to enter next round", async () => {
    const deposit = 1000;
    await expect(
      RockPaperScissorsContract.enterNextRound(deposit, {
        value: deposit - 1,
      })
    ).to.be.revertedWith("Amount is not equal to funds sent");
  });

  it("Can select a move after paying", async () => {
    const deposit = 1000;
    await RockPaperScissorsContract.enterNextRound(deposit, {
      value: deposit,
    });

    await RockPaperScissorsContract.chooseRock();
  });

  it("Cannot select a move before paying", async () => {
    await expect(RockPaperScissorsContract.chooseRock()).to.be.revertedWith(
      "Player has not payed for next round"
    );
  });

  it("Cannot set move if opponent hasn't payed", async () => {
    const deposit = "10000000000000000000";
    const addr2Address = await addr2.getAddress();
    const addr3Address = await addr3.getAddress();

    await RockPaperScissorsContract.connect(addr2).enterNextRound(deposit, {
      value: deposit,
    });

    await expect(
      RockPaperScissorsContract.connect(addr2).chooseRockAgainst(addr3Address)
    ).to.be.revertedWith("opponent has not payed for next round");
  });

  it("Recieve all funds after winning game a move after paying", async () => {
    const deposit = "10000000000000000000";

    await RockPaperScissorsContract.connect(owner).enterNextRound(deposit, {
      value: deposit,
    });

    await RockPaperScissorsContract.connect(addr1).enterNextRound(deposit, {
      value: deposit,
    });

    expect(
      BigNumber.from(await RockPaperScissorsContract.getBalance())
    ).to.equal((deposit * 2).toString());

    await RockPaperScissorsContract.connect(addr1).chooseRock();
    const balanceAfterChoosingMove = BigNumber.from(await addr1.getBalance());

    await RockPaperScissorsContract.connect(owner).chooseScissors();

    await RockPaperScissorsContract.connect(addr1).getWinnings();

    expect(
      BigNumber.from(await RockPaperScissorsContract.getBalance())
    ).to.equal(0);

    const balanceAfterWinning = BigNumber.from(await addr1.getBalance());
    const winnings = BigNumber.from((parseInt(deposit, 10) * 2).toString());
    const expectedFinalBalance = winnings.add(balanceAfterChoosingMove);

    expect(balanceAfterWinning.gt(balanceAfterChoosingMove)).to.eq(true);
  });

  it("Can challenge a specific player and get winnings", async () => {
    const deposit = "10000000000000000000";
    const addr2Address = await addr2.getAddress();
    const addr3Address = await addr3.getAddress();

    await RockPaperScissorsContract.connect(addr2).enterNextRound(deposit, {
      value: deposit,
    });

    await RockPaperScissorsContract.connect(addr3).enterNextRound(deposit, {
      value: deposit,
    });

    expect(
      BigNumber.from(await RockPaperScissorsContract.getBalance())
    ).to.equal((deposit * 2).toString());

    await RockPaperScissorsContract.connect(addr2).chooseRockAgainst(
      addr3Address
    );

    const balanceAfterChoosingMove = BigNumber.from(await addr2.getBalance());

    await RockPaperScissorsContract.connect(addr3).chooseScissorsAgainst(
      addr2Address
    );

    await RockPaperScissorsContract.connect(addr2).getWinnings();

    expect(
      BigNumber.from(await RockPaperScissorsContract.getBalance())
    ).to.equal(0);

    const balanceAfterWinning = BigNumber.from(await addr2.getBalance());
    const winnings = BigNumber.from((parseInt(deposit, 10) * 2).toString());
    const expectedFinalBalance = winnings.add(balanceAfterChoosingMove);
    expect(balanceAfterWinning.gt(balanceAfterChoosingMove)).to.eq(true);
  });

  it("If you draw a game you can play again in randomly assigned game", async () => {
    const deposit = "10000000000000000000";

    await RockPaperScissorsContract.connect(owner).enterNextRound(deposit, {
      value: deposit,
    });

    await RockPaperScissorsContract.connect(addr1).enterNextRound(deposit, {
      value: deposit,
    });

    expect(
      BigNumber.from(await RockPaperScissorsContract.getBalance())
    ).to.equal((deposit * 2).toString());

    await RockPaperScissorsContract.connect(addr1).chooseRock();
    const balanceAfterChoosingMove = BigNumber.from(await addr1.getBalance());

    await RockPaperScissorsContract.connect(owner).chooseRock();

    expect(
      BigNumber.from(await RockPaperScissorsContract.getBalance())
    ).to.equal((deposit * 2).toString());

    await RockPaperScissorsContract.connect(addr1).chooseRock();
    await RockPaperScissorsContract.connect(owner).chooseScissors();

    await RockPaperScissorsContract.connect(addr1).getWinnings();

    const balanceAfterWinning = BigNumber.from(await addr1.getBalance());
    const winnings = BigNumber.from((parseInt(deposit, 10) * 2).toString());
    const expectedFinalBalance = winnings.add(balanceAfterChoosingMove);

    expect(balanceAfterWinning.gt(balanceAfterChoosingMove)).to.eq(true);
  });

  it("If you draw a game you can play again in custom game", async () => {
    const deposit = "10000000000000000000";
    const addr2Address = await addr2.getAddress();
    const addr3Address = await addr3.getAddress();

    await RockPaperScissorsContract.connect(addr2).enterNextRound(deposit, {
      value: deposit,
    });

    await RockPaperScissorsContract.connect(addr3).enterNextRound(deposit, {
      value: deposit,
    });

    expect(
      BigNumber.from(await RockPaperScissorsContract.getBalance())
    ).to.equal((deposit * 2).toString());

    await RockPaperScissorsContract.connect(addr2).chooseScissorsAgainst(
      addr3Address
    );

    await RockPaperScissorsContract.connect(addr3).chooseScissorsAgainst(
      addr2Address
    );

    expect(
      BigNumber.from(await RockPaperScissorsContract.getBalance())
    ).to.equal((deposit * 2).toString());

    const balanceAfterChoosingMove = BigNumber.from(await addr3.getBalance());

    await RockPaperScissorsContract.connect(addr2).chooseScissorsAgainst(
      addr3Address
    );

    await RockPaperScissorsContract.connect(addr3).chooseRockAgainst(
      addr2Address
    );

    await RockPaperScissorsContract.connect(addr3).getWinnings();

    expect(
      BigNumber.from(await RockPaperScissorsContract.getBalance())
    ).to.equal(0);

    const balanceAfterWinning = BigNumber.from(await addr3.getBalance());
    expect(balanceAfterWinning.gt(balanceAfterChoosingMove)).to.eq(true);
  });

  it("Can bet previous winnings", async () => {
    const deposit = "10000000000000000000";

    await RockPaperScissorsContract.connect(owner).enterNextRound(deposit, {
      value: deposit,
    });

    await RockPaperScissorsContract.connect(addr1).enterNextRound(deposit, {
      value: deposit,
    });

    expect(
      BigNumber.from(await RockPaperScissorsContract.getBalance())
    ).to.equal((deposit * 2).toString());

    await RockPaperScissorsContract.connect(addr1).chooseRock();
    await RockPaperScissorsContract.connect(owner).chooseScissors();

    const balanceAfterChoosingMove = BigNumber.from(await addr1.getBalance());

    await RockPaperScissorsContract.connect(addr1).betWinnings();
    await RockPaperScissorsContract.connect(owner).enterNextRound(deposit, {
      value: deposit,
    });

    await RockPaperScissorsContract.connect(addr1).chooseRock();
    await RockPaperScissorsContract.connect(owner).chooseScissors();

    expect(
      BigNumber.from(await RockPaperScissorsContract.getBalance())
    ).to.equal((deposit * 3).toString());

    await RockPaperScissorsContract.connect(addr1).getWinnings();

    const balanceAfterWinning = BigNumber.from(await addr1.getBalance());
    const winnings = BigNumber.from((parseInt(deposit, 10) * 2).toString());
    const expectedFinalBalance = winnings.add(balanceAfterChoosingMove);

    expect(balanceAfterWinning.gt(balanceAfterChoosingMove)).to.eq(true);
  });
});
