import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { FakeContract, smock } from '@defi-wonderland/smock'

import {
  KlimaToken,
  KlimaToken__factory,
  SKLIMAv2,
  SKLIMAv2__factory,
  KlimaStaking,
} from '../../types';

const TOTAL_GONS = 5000000000000000;
const ZERO_ADDRESS = ethers.constants.AddressZero;

describe("sKlima", () => {
  let initializer: SignerWithAddress;
  let authority: SignerWithAddress;
  let alice: SignerWithAddress;
  let bob: SignerWithAddress;
  let klima: KlimaToken;
  let sKlima: SKLIMAv2;
  let stakingFake: FakeContract<KlimaStaking>;

  beforeEach(async () => {
    [initializer, authority, alice, bob] = await ethers.getSigners();
    stakingFake = await smock.fake<KlimaStaking>('contracts/staking/regular/KlimaStaking_v2.sol:KlimaStaking');

    klima = await (new KlimaToken__factory(initializer)).deploy();
    await klima.setVault(authority.address);
    sKlima = await (new SKLIMAv2__factory(initializer)).deploy();
  });

  it("is constructed correctly", async () => {
    expect(await sKlima.name()).to.equal("Staked Klima");
    expect(await sKlima.symbol()).to.equal("sKLIMA");
    expect(await sKlima.decimals()).to.equal(9);
  });

  describe("initialization", () => {
    describe("setIndex", () => {
      it("sets the index", async () => {
        await sKlima.connect(initializer).setIndex(3);
        expect(await sKlima.index()).to.equal(3);
      });

      it("must be done by the initializer", async () => {
        await expect(sKlima.connect(alice).setIndex(3)).to.be.reverted;
      });

      it("cannot update the index if already set", async () => {
        await sKlima.connect(initializer).setIndex(3);
        await expect(sKlima.connect(initializer).setIndex(3)).to.be.reverted;
      });
    });

    describe("initialize", () => {
      it("assigns TOTAL_GONS to the stakingFake contract's balance", async () => {
        await sKlima.connect(initializer).initialize(stakingFake.address);
        expect(await sKlima.balanceOf(stakingFake.address)).to.equal(TOTAL_GONS);
      });

      it("emits Transfer event", async () => {
        await expect(sKlima.connect(initializer).initialize(stakingFake.address)).
          to.emit(sKlima, "Transfer").withArgs(ZERO_ADDRESS, stakingFake.address, TOTAL_GONS);
      });

      it("emits LogStakingContractUpdated event", async () => {
        await expect(sKlima.connect(initializer).initialize(stakingFake.address)).
          to.emit(sKlima, "LogStakingContractUpdated").withArgs(stakingFake.address);
      });

      it("unsets the initializer, so it cannot be called again", async () => {
        await sKlima.connect(initializer).initialize(stakingFake.address);
        await expect(sKlima.connect(initializer).initialize(stakingFake.address)).to.be.reverted;
      });
    });
  });

  describe("post-initialization", () => {
    beforeEach(async () => {
      await sKlima.connect(initializer).setIndex(1);
      await sKlima.connect(initializer).initialize(stakingFake.address);
    });

    describe("approve", () => {
      it("sets the allowed value between sender and spender", async () => {
        await sKlima.connect(alice).approve(bob.address, 10);
        expect(await sKlima.allowance(alice.address, bob.address)).to.equal(10);
      });

      it("emits an Approval event", async () => {
        await expect(await sKlima.connect(alice).approve(bob.address, 10)).
          to.emit(sKlima, "Approval").withArgs(alice.address, bob.address, 10);
      });
    });

    describe("increaseAllowance", () => {
      it("increases the allowance between sender and spender", async () => {
        await sKlima.connect(alice).approve(bob.address, 10);
        await sKlima.connect(alice).increaseAllowance(bob.address, 4);

        expect(await sKlima.allowance(alice.address, bob.address)).to.equal(14);
      });

      it("emits an Approval event", async () => {
        await sKlima.connect(alice).approve(bob.address, 10);
        await expect(await sKlima.connect(alice).increaseAllowance(bob.address, 4)).
          to.emit(sKlima, "Approval").withArgs(alice.address, bob.address, 14);
      });
    });

    describe("decreaseAllowance", () => {
      it("decreases the allowance between sender and spender", async () => {
        await sKlima.connect(alice).approve(bob.address, 10);
        await sKlima.connect(alice).decreaseAllowance(bob.address, 4);

        expect(await sKlima.allowance(alice.address, bob.address)).to.equal(6);
      });

      it("will not make the value negative", async () => {
        await sKlima.connect(alice).approve(bob.address, 10);
        await sKlima.connect(alice).decreaseAllowance(bob.address, 11);

        expect(await sKlima.allowance(alice.address, bob.address)).to.equal(0);
      });

      it("emits an Approval event", async () => {
        await sKlima.connect(alice).approve(bob.address, 10);
        await expect(await sKlima.connect(alice).decreaseAllowance(bob.address, 4)).
          to.emit(sKlima, "Approval").withArgs(alice.address, bob.address, 6);
      });
    });

    // TODO: Properly test how circulating supply is calculated
    describe("circulatingSupply", () => {
      it("is zero when all owned by stakingFake contract", async () => {
        const totalSupply = await sKlima.circulatingSupply();
        expect(totalSupply).to.equal(0);
      });

      // it("includes all supply owned by gOhmFake", async () => {
      //   const totalSupply = await sOhm.circulatingSupply();
      //   expect(totalSupply).to.equal(10);
      // });


      // it("includes all supply in warmup in stakingFake contract", async () => {
      //   await stakingFake.supplyInWarmup.returns(50);
      //   await gOhmFake.totalSupply.returns(0);
      //   await gOhmFake.balanceFrom.returns(0);

      //   const totalSupply = await sOhm.circulatingSupply();
      //   expect(totalSupply).to.equal(50);
      // });
    });
  });
});