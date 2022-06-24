import { ethers } from 'hardhat'

async function main() {
    const MyNFT = await ethers.getContractFactory('MyNFT')
    const contract = await MyNFT.deploy(1)
    await contract.deployed()
    console.log('MyNFT deployed to:', contract.address)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
