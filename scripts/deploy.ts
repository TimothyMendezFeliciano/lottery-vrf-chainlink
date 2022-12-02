import {ethers} from 'hardhat'
import * as dotenv from 'dotenv';
import {FEE, KEY_HASH, LINK_TOKEN, VRF_COORDINATOR} from "../constants";

dotenv.config({path: ".env"})

async function main() {
    const randomWinnerGame = await ethers.getContractFactory("RandomWinnerGame");
    const deployedRandomWinnerGameContract = await randomWinnerGame.deploy(
        VRF_COORDINATOR,
        LINK_TOKEN,
        KEY_HASH,
        FEE
    )

    await deployedRandomWinnerGameContract.deployed();

    console.log(
        "Verify Contract Address:",
        deployedRandomWinnerGameContract.address
    );

    console.log("Sleeping.....");
    // Wait for etherscan to notice that the contract has been deployed
    await sleep(30000);

    await hre.run("verify:verify", {
        address: deployedRandomWinnerGameContract.address,
        constructorArguments: [VRF_COORDINATOR, LINK_TOKEN, KEY_HASH, FEE]
    })
}

function sleep(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms))
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1)
    })
