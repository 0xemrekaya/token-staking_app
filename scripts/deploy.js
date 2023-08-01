

const hre = require("hardhat");

async function main() {

    const emre = await hre.ethers.deployContract("Emre");
  
    await emre.waitForDeployment();
    const result = await emre.getAddress();
  
    console.log("Contract deployed to: ", result);
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});