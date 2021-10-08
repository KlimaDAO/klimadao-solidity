const { ethers, upgrades } = require("hardhat");

/*
   Deploys KLIMA and sKLIMA
 */

const mainnetKLIMA = "0x4e78011ce80ee02d2c3e649fb657e45898257815";
const mainnetaKLIMA = "0xeb935614447185eeea0abc756ff2ddc99fbb9047";
const mainnetalKLIMA = "0xd50EC6360f560a59926216Eafb98395AC430C9fD";

async function main() {
  const KlimaRedeemer = await ethers.getContractFactory("AlphaKlimaRedeemUpgradeable");

  const KlimaRedeemerA = await upgrades.deployProxy(KlimaRedeemer,[mainnetKLIMA, mainnetaKLIMA, "0x0000000000000000000000000000000000000000"]);
  await KlimaRedeemerA.deployed();
  console.log("AKlima Redeemer Deployed at: ", KlimaRedeemerA.address);

  const KlimaRedeemerAl = await upgrades.deployProxy(KlimaRedeemer,[mainnetKLIMA, mainnetalKLIMA, "0x0000000000000000000000000000000000000000"]);
  await KlimaRedeemerAl.deployed();
  console.log("AlKlima Redeemer Deployed at: ", KlimaRedeemerAl.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
