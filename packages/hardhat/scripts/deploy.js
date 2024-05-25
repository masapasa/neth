// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
    // You need to replace 'cEURTokenAddress' with the actual deployed address of the cEUR token contract
    const cEURTokenAddress = "0x9Cb5629798eb152C2A31Ff54768F8b741Dc0f4e7";

    const MentoStaker = await hre.ethers.getContractFactory("MentoStaker");
    const mentoStaker = await MentoStaker.deploy(cEURTokenAddress);

    await mentoStaker.deployed();

    console.log(`MentoStaker deployed to ${mentoStaker.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
