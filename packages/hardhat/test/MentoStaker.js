const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("MentoStaker", function () {
  let cEURToken, mentoStaker;
  let owner, addr1, addr2;

  // Use async arrow function for consistency
  beforeEach(async () => {
    // Correctly getting the signers
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy the mock cEURToken
    const Token = await ethers.getContractFactory("Token");
    cEURToken = await Token.deploy("cEURToken", "cEUR", ethers.utils.parseEther("1000000"));
    await cEURToken.deployed();

    // Deploy the MentoStaker contract
    const MentoStaker = await ethers.getContractFactory("MentoStaker");
    mentoStaker = await MentoStaker.deploy(cEURToken.address);
    await mentoStaker.deployed();

    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    // Distribute cEUR tokens to addr1 and addr2 for testing
    await cEURToken.transfer(addr1.address, ethers.utils.parseEther("1000"));
    await cEURToken.transfer(addr2.address, ethers.utils.parseEther("1000"));
  });

  describe("Staking", function () {
    it("Should allow users to stake cEUR tokens", async function () {
      // Approve and stake cEUR tokens
      await cEURToken.connect(addr1).approve(mentoStaker.address, ethers.utils.parseEther("100"));
      await mentoStaker.connect(addr1).stake(ethers.utils.parseEther("100"));

      expect(await mentoStaker.totalStaked()).to.equal(ethers.utils.parseEther("100"));
      const stake = await mentoStaker.stakes(addr1.address);
      expect(stake.amount).to.equal(ethers.utils.parseEther("100"));
    });

    it("Should fail if user tries to stake 0 cEUR", async function () {
      await expect(mentoStaker.connect(addr1).stake(0)).to.be.revertedWith("AmountShouldBeMoreThanZero");
    });
  });

  describe("Adding Rewards", function () {
    it("Should allow owner to add rewards", async function () {
      // Transfer cEUR to MentoStaker for rewards
      await cEURToken.connect(owner).approve(mentoStaker.address, ethers.utils.parseEther("500"));
      await mentoStaker.connect(owner).addRewards(ethers.utils.parseEther("500"));

      expect(await mentoStaker.totalRewards()).to.equal(ethers.utils.parseEther("500"));
    });

    it("Should not allow non-owner to add rewards", async function () {
      await expect(
        mentoStaker.connect(addr1).addRewards(ethers.utils.parseEther("500"))
      ).to.be.revertedWith("NotOwner");
    });
  });

  describe("Withdrawing", function () {
    beforeEach(async function () {
      // Setup initial stake
      await cEURToken.connect(addr1).approve(mentoStaker.address, ethers.utils.parseEther("100"));
      await mentoStaker.connect(addr1).stake(ethers.utils.parseEther("100"));
    });

    it("Should allow users to withdraw their stake and rewards", async function () {
      // Add rewards
      await cEURToken.connect(owner).approve(mentoStaker.address, ethers.utils.parseEther("500"));
      await mentoStaker.connect(owner).addRewards(ethers.utils.parseEther("500"));

      // Withdraw stake and rewards
      const initialBalance = await cEURToken.balanceOf(addr1.address);
      await mentoStaker.connect(addr1).withdraw();
      const finalBalance = await cEURToken.balanceOf(addr1.address);

      expect(finalBalance.sub(initialBalance)).to.be.closeTo(ethers.utils.parseEther("600"), ethers.utils.parseEther("0.01"));
    });

    it("Should fail if there's no balance to withdraw", async function () {
      await expect(mentoStaker.connect(addr2).withdraw()).to.be.revertedWith("NoBalanceToWithdraw");
    });
  });

  describe("Permissions and Failures", function () {
    it("Should not allow non-owner to perform owner withdrawals", async function () {
      await expect(mentoStaker.connect(addr1).ownerWithdraw()).to.be.revertedWith("NotOwner");
    });
  });
});
