const {ethers} = require('hardhat')
const hre = require("@nomicfoundation/hardhat-ethers");
// For deploying in testnet:
// npx hardhat run ./scripts/LOCGOptimism.js --network opsepolia

// Optimism Example
// _BRIDGE:      "0x4200000000000000000000000000000000000010"
// _REMOTETOKEN: "0xC130493b32342554751F1f13F5A5a09BB9B33DED"
// _NAME:        "LOCGame Bridged"
// _SYMBOL:      "LOCG"

async function main(hre) {
    const {network} = hre
    const signers = await ethers.getSigners()
    console.log("Dao Multisig: ", signers[0].address)
    // Deploying contract
    const locgBridged = await ethers.getContractFactory('LOCGBridged')
    const instance = await locgBridged.deploy("0x4200000000000000000000000000000000000010", "0xC130493b32342554751F1f13F5A5a09BB9B33DED", "LOCGame", "LOCG")
    await instance.waitForDeployment()

    console.log('Contract deployed to:', await instance.getAddress())
}

main(hre)