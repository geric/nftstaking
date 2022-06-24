import { ethers } from 'hardhat'

async function main() {
    const NFTStaking = await ethers.getContractFactory('NFTStaking')
    const contract = await NFTStaking.deploy("0xA049eAeE34DD4B64e3635E3758d30FAd454b223D")
    await contract.deployed()
    console.log('NFTStaking deployed to:', contract.address)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
