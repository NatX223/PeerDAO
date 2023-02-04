const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");
  const { ethers } = require("hardhat");
  const BigNumber = require("bignumber.js");

  describe("Contracts Deployment", function () {
    async function LoadFixture() {
        const name = "PeerDAO";
        const symbol = "PED";
        const [owner, otherAccount] = await ethers.getSigners();
        ONE_FIL = 1000000000000000000n;

        const Token = await ethers.getContractFactory("peerToken");
        const token = await Token.deploy(name, symbol);

        const tokenAddress = token.address;

        const joinAmount = 5000000000000000000n
        const contributionAmount = 2000000000000000000n
        const successThreshold = 10;
        const accessAmount = 500000000000000000n

        const purchaseAmount = ONE_FIL;

        const DAOCONTRACT = await ethers.getContractFactory("PeerDAO");
        const daocontract = await DAOCONTRACT.deploy(tokenAddress, joinAmount, contributionAmount, successThreshold, accessAmount);

        const DAOaddress = daocontract.address;

        await token.buyToken({ value: purchaseAmount});
        await token.connect(otherAccount).buyToken({ value: purchaseAmount});

        const balance = token.balanceOf(owner.address);

        const amount = 5;

        return { purchaseAmount, amount, owner, otherAccount, token, tokenAddress, daocontract, balance, DAOaddress, joinAmount, contributionAmount }
    }

    describe("JoinDAO", function () {
        it("should join dao successfully", async function () {
          const { daocontract, balance, token, DAOaddress, joinAmount } = await loadFixture(LoadFixture);
    
          const role = "Content Creator";

          await token.approve(DAOaddress, joinAmount);
          await daocontract.joinDAO(role);

          const allMembers = await daocontract.getAllMembers();
        
          console.log(balance, allMembers);
        });
      });

      describe("buyToken", function () {
        it("should buy token successfully", async function () {
          const { token, amount, owner } = await loadFixture(LoadFixture);
          const _amount = amount * (10 ** 18);
          const purchaseAmount = BigInt(_amount);
          await token.buyToken({value: purchaseAmount});
          
          const balance = token.balanceOf(owner.address);

          console.log(balance);
        });
      });

      describe("create proposal", function () {
        it("should create proposal successfully", async function () {
          const { balance, daocontract, token, DAOaddress, contributionAmount } = await loadFixture(LoadFixture);

            await token.approve(DAOaddress, contributionAmount);
            await daocontract.createProposal("hash", "video of funny cats");

            const proposals = await daocontract.getAllProposals();

          console.log(balance, proposals);

        });
      });
  });