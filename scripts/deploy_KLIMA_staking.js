const { ethers } = require("hardhat");

/*
   Deploys KLIMA staking contracts
 */
async function main() {
  // epoch length in blocks
  const epochLength = 11520;
  // first epoch number
  const firstEpochNumber = 0;
  // first epoch block
  const firstEpochBlock = 0;

  const KlimaStaking = await ethers.getContractFactory("KlimaStaking");
  const klimaStaking = await KlimaStaking.deploy(
    process.env.KLIMA_ERC20_ADDRESS,
    process.env.SKLIMA_ERC20_ADDRESS,
    epochLength,
    firstEpochNumber,
    firstEpochBlock
  );
  console.log("Klima Staking deployed at: ", klimaStaking.address);

  const StakingHelper = await ethers.getContractFactory("StakingHelper");
  const stakingHelper = await StakingHelper.deploy(
    klimaStaking.address,
    process.env.KLIMA_ERC20_ADDRESS
  );
  console.log("Staking Helper deployed at: ", stakingHelper.address);

  const StakingWarmup = await ethers.getContractFactory("StakingWarmup");
  const stakingWarmup = await StakingWarmup.deploy(
    klimaStaking.address,
    process.env.SKLIMA_ERC20_ADDRESS
  );
  console.log("Staking Warmup deployed at: ", stakingWarmup.address);

  const KlimaDistributor = await ethers.getContractFactory("Distributor");
  const klimaDistributor = await KlimaDistributor.deploy(
    process.env.KLIMA_TREASURY_ADDRESS,
    process.env.KLIMA_ERC20_ADDRESS,
    epochLength,
    firstEpochBlock
  );
  console.log("Klima Distributor deployed at: ", klimaDistributor.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
