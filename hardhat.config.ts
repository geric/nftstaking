import '@nomiclabs/hardhat-waffle'
import '@typechain/hardhat'
import { HardhatUserConfig } from 'hardhat/config'
import '@nomiclabs/hardhat-etherscan'
import './tasks/basic-task'
import secrets from './secrets.json'

const config: HardhatUserConfig = {
    defaultNetwork: 'hardhat',
    solidity: {
        version: '0.8.4',
        settings: {
            optimizer: {
                enabled: true,
                runs: 200,
            },
        },
    },
    networks: {
        bsctestnet: {
            url: 'https://data-seed-prebsc-1-s1.binance.org:8545',
            chainId: 97,
            gasPrice: 20000000000,
            accounts: [`0x${secrets.BSC_TESTNET_DEPLOYER_PPK}`],
        },
        mainnet: {
            url: 'https://bsc-dataseed.binance.org/',
            chainId: 56,
            gasPrice: 20000000000,
            accounts: [`0x${secrets.BSC_MAINNET_DEPLOYER_PPK}`],
        },
        rinkeby: {
            url: 'https://rinkeby.infura.io/v3/fe8337e0438340c5b5eb9d22addcbcc9',
            accounts: [`0x${secrets.ETH_RINKEBY_DEVELOPER_PPK}`],
        }
    },
    etherscan: {
        apiKey: secrets.ETH_SCAN_API_KEY,
    },
}

export default config
