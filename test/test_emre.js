
const { expect } = require("chai");
const { ethers } = require("hardhat");
const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("Emre", function () {
  async function deployEmreTokenFixture() {
    const [owner, addr1, addr2] = await ethers.getSigners();
    const Emre = await ethers.getContractFactory("Emre");
    const emre = await Emre.deploy();
    return { emre, owner, addr1, addr2 };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { emre, owner } = await loadFixture(deployEmreTokenFixture);
      expect(await emre.owner()).to.equal(owner.address);
    });
    it("Max token supply has to equal to 100000e18", async function () {
      const { emre } = await loadFixture(deployEmreTokenFixture);
      const totalSupply = ethers.getBigInt("100000000000000000000000"); //100000e18 tokens
      expect(await emre.totalSupply()).to.equal(totalSupply);
    });
    it("Max token supply has to equal to Owner's balance of token", async function () {
      const { emre, owner } = await loadFixture(deployEmreTokenFixture);
      const { _totalSupply } = await emre.totalSupply();
      const { _ownerBalanceOf } = await emre.balanceOf(owner.address);
      expect(_totalSupply).to.equal(_ownerBalanceOf);
    });

  });
  describe("Transfer", function () {
    it("Should transfer with transfer func.", async function () {
      const { emre, owner, addr1, addr2 } = await loadFixture(deployEmreTokenFixture);
      await emre.connect(owner).transfer(addr1.address, 100)
      expect(await emre.balanceOf(addr1.address)).to.equal(100);
    });
    it("Should transfer with transferFrom func.", async function () {
      const { emre, owner, addr1, addr2 } = await loadFixture(deployEmreTokenFixture);
      await emre.connect(owner).approve(addr1.address, 100); //allowance for transfer
      await emre.connect(addr1).transferFrom(owner.address, addr1.address, 100)
      expect(await emre.balanceOf(addr1.address)).to.equal(100);
    });
  });
  describe("Mint", function () {
    it("Owner should mint token", async function () {
      const { emre, owner, addr1 } = await loadFixture(deployEmreTokenFixture);
      const totalSupply = ethers.getBigInt("100000000000000000000000");
      const value = ethers.getBigInt("100");
      await emre.connect(owner).mint(addr1, value);
      //addr1 must have only 100 tokens.
      expect(await emre.balanceOf(addr1.address)).to.equal(value);

      //totalSupply is changed 100000e18 + 100 tokens.
      expect(await emre.totalSupply()).to.equal(totalSupply + value);
    });
    it("If another account wants to mint, it should be doesnt work", async function () {
      const { emre, owner, addr1 } = await loadFixture(deployEmreTokenFixture);
      const totalSupply = ethers.getBigInt("100000000000000000000000");
      const value = ethers.getBigInt("100");
      try {
        // Here, perform an action that triggers an expected accident
        await emre.connect(addr1).mint(addr1, value);
        expect.fail("Expected an exception but none was received.");
      } catch (error) {
        expect(error.message).to.include("Ownable: caller is not the owner");
      }
    });
  });
  describe("Burn", function () {
    it("Everybody should burn own token", async function () {
      const { emre, owner, addr1, addr2 } = await loadFixture(deployEmreTokenFixture);
      const totalSupply = ethers.getBigInt("100000000000000000000000");
      const value = ethers.getBigInt("100");

      await emre.connect(owner).transfer(addr1.address, value)
      expect(await emre.balanceOf(addr1.address)).to.equal(value);

      await emre.connect(addr1).burn(value);
      expect(await emre.balanceOf(addr1.address)).to.equal(0);
      expect(await emre.totalSupply()).to.not.equal(totalSupply);
      expect(await emre.totalSupply()).to.equal(totalSupply - value);

    });
    it("If burn amount exceeds balance then thrown exception", async function () { //ERC20: burn amount exceeds balance
      const { emre, addr1, addr2 } = await loadFixture(deployEmreTokenFixture);
      const value = ethers.getBigInt("100");
      try {
        // Here, perform an action that triggers an expected accident
        //addr1 doesnt have any tokens.
        await emre.connect(addr1).burn(value);
        expect.fail("Expected an exception but none was received.");
      } catch (error) {
        expect(error.message).to.include("ERC20: burn amount exceeds balance");
      }
    });
  });
  describe("Transfer ownership", function () {
    it("Owner should transfer ownership", async function () {
      const { emre, owner, addr1 } = await loadFixture(deployEmreTokenFixture);

      await emre.connect(owner).transferOwnership(addr1);
      expect(await emre.owner()).to.equal(addr1.address);
      expect(await emre.owner()).to.not.equal(owner.address);

    });
    it("If another account wants to Transfer ownership, it should be doesnt work", async function () {
      const { emre, addr1, addr2 } = await loadFixture(deployEmreTokenFixture);
      try {
        // Here, perform an action that triggers an expected accident
        await emre.connect(addr1).transferOwnership(addr2);
        expect.fail("Expected an exception but none was received.");
      } catch (error) {
        expect(error.message).to.include("Ownable: caller is not the owner");
      }
    });
  });

});
