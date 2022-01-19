import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import "@nomiclabs/hardhat-waffle"
import { ethers } from "hardhat";


import {
  KlimaToken as OlympusERC20Token,
  KlimaToken__factory as OlympusERC20Token__factory,
  // OlympusAuthority__factory
} from '../../types';

describe("OlympusTest", () => {
  let deployer: SignerWithAddress;
  let vault: SignerWithAddress;
  let bob: SignerWithAddress;
  let alice: SignerWithAddress;
  let klima: OlympusERC20Token;

  beforeEach(async () => {
    [deployer, vault, bob, alice] = await ethers.getSigners();

    klima = await (new OlympusERC20Token__factory(deployer)).deploy();

  });

  it("correctly constructs an ERC20", async () => {
    expect(await klima.name()).to.equal("Klima DAO");
    expect(await klima.symbol()).to.equal("KLIMA");
    expect(await klima.decimals()).to.equal(9);
  });

  describe("mint", () => {
    it("must be done by vault", async () => {
      await expect(klima.connect(deployer).mint(bob.address, 100)).
        to.be.revertedWith("UNAUTHORIZED");
    });

    it("increases total supply", async () => {
      let supplyBefore = await klima.totalSupply();
      await klima.connect(vault).mint(bob.address, 100);
      expect(supplyBefore.add(100)).to.equal(await klima.totalSupply());
    });
  });

  describe("burn", () => {
    beforeEach(async () => {
      await klima.connect(vault).mint(bob.address, 100);
    });

    it("reduces the total supply", async () => {
      let supplyBefore = await klima.totalSupply();
      await klima.connect(bob).burn(10);
      expect(supplyBefore.sub(10)).to.equal(await klima.totalSupply());
    });

    it("cannot exceed total supply", async () => {
      let supply = await klima.totalSupply();
      await expect(klima.connect(bob).burn(supply.add(1))).
        to.be.revertedWith("ERC20: burn amount exceeds balance");
    });

    it("cannot exceed bob's balance", async () => {
      await klima.connect(vault).mint(alice.address, 15);
      await expect(klima.connect(alice).burn(16)).
        to.be.revertedWith("ERC20: burn amount exceeds balance");
    });
  });
});