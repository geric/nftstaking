import { ethers, network } from 'hardhat'
import {
    MyNFT,
    MyNFT__factory,
    NFTStaking,
    NFTStaking__factory,
} from '../typechain-types'
import { expect, should } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { providers } from 'ethers'

const SECONDS_IN_A_DAY = 86400

async function moveTime(amount: number) {
    await network.provider.send('evm_increaseTime', [amount])
}

// mine 40 blocks
async function moveBlocks() {
    await network.provider.send("hardhat_mine", ["0x28"])
}

describe('NFTStaking', function () {
    let MyNFT: MyNFT
    let MyNFT__factory: MyNFT__factory
    let NFTStaking: NFTStaking
    let NFTStaking__factory: NFTStaking__factory

    let owner: SignerWithAddress
    let addr1: SignerWithAddress
    let addr2: SignerWithAddress
    let addr3: SignerWithAddress
    let addrs: SignerWithAddress[]

    this.beforeEach(async () => {
        ;[owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners()

        MyNFT__factory = await ethers.getContractFactory('MyNFT')
        // deployed with max supply of 100
        MyNFT = await MyNFT__factory.deploy(100)

        NFTStaking__factory = await ethers.getContractFactory('NFTStaking')
        NFTStaking = await NFTStaking__factory.deploy(MyNFT.address)

        // approve NFTStaking
        await MyNFT.setApprovalForAll(NFTStaking.address, true)

        // lets fund the NFTStaking Contract
        await owner.sendTransaction({
            to: NFTStaking.address,
            value: ethers.utils.parseEther('100'),
        })

        // lets mint the NFT
        await MyNFT.mint('https://api.example.com/tokens/{id}')
    })

    describe('Staking', () => {
        it('Should allow user to stake their NFT and transfer NFT to the staking contract', async () => {
            await NFTStaking.stake(0)
            await expect(NFTStaking.stakers(owner.address)).to.not.be.reverted
            expect(await MyNFT.balanceOf(owner.address, 0)).to.be.equal(99)
        })
    })

    describe('Unstake', () => {
        it('Should not allow users to unstake their NFT during the unlock period', async () => {
            await NFTStaking.stake(0)
            await expect(NFTStaking.unstake()).to.be.reverted;
        })

        it('Should allow users to unstake their NFT and get their rewards', async () => {
            await NFTStaking.stake(0)
            moveTime(SECONDS_IN_A_DAY * 2);
            //37th block moved to 77th block (+40 blocks)
            // 0.001 * 40 = 0.04
            // 0.04 eth = 40000000000000000
            moveBlocks();
            expect(await NFTStaking.checkRewards(owner.address)).to.equal("40000000000000000");
            await expect(NFTStaking.unstake()).to.not.be.reverted;
            // +1 block after unstaking and the rewards are immediately transferred to the user's wallet
            expect(await NFTStaking.provider.getBalance(owner.address)).to.be.equal("9700016925323010126307");
            // i haven't thought of a solution yet to compute the exact eth amount after gas fee, +1 block mine reward
        })
    })
})
