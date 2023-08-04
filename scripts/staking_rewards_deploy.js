

const hre = require("hardhat");

async function main() {

    const StakingRewards = await hre.ethers.getContractFactory("StakingRewards");
    const EmreTokenAddress = hre.ethers.getAddress("0x408A75B834DAA994dd9c421e095E0c527d16104B");
    const stakingRewards = await StakingRewards.deploy(EmreTokenAddress, EmreTokenAddress);

    await stakingRewards.waitForDeployment();
    const result = await stakingRewards.getAddress();

    console.log("Contract deployed to: ", result);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});