const {ethers} = require('hardhat')
const hre = require("@nomicfoundation/hardhat-ethers");
// For deploying in testnet:
// npx hardhat run ./scripts/LOCG.js --network sepolia

async function main(hre) {
    const {network} = hre
    const signers = await ethers.getSigners()
    console.log("Dao Multisig: ", signers[0].address)
    // Deploying contract
    const locgERC20 = await ethers.getContractFactory('LOCG')
    const instance = await locgERC20.deploy(signers[0].address)
    await instance.waitForDeployment()

    console.log('Contract deployed to:', await instance.getAddress())
}

main(hre)