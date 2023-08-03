

const hre = require("hardhat");

async function main() {

    const StakingRewards = await hre.ethers.getContractFactory("StakingRewards");
    const EmreTokenAddress = hre.ethers.getAddress("0x054958005fD87355FD7B7d145Cf26D820D657B06");
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