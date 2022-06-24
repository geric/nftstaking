// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "hardhat/console.sol";

contract NFTStaking {
    IERC1155 public immutable nft;
    uint256 public constant TIMELOCK = 1 days;

    //TODO staking period

    // we limit that only 1 NFT can be staked per address
    // based on the requirements defined, the amount of staked NFT does not matter
    struct Staker {
        uint256 tokenId;
        uint256 stakedBlockNumber;
        uint256 stakedTime;
        uint256 amount;
        uint256 unlockPeriod;
    }

    mapping(address => Staker) public stakers;

    constructor(address _nft) {
        nft = IERC1155(_nft);
    }

    // allow this smart contract to receive ETH
    // for simplicity, let's allow any sender ;)
    receive() external payable {}

    function isAddressStaking(address addr) public view returns (bool) {
        if (stakers[addr].stakedBlockNumber != 0) {
            return true;
        }
        return false;
    }

    function stake(uint256 _tokenId) public {
        // check if user is already staking
        require(
            isAddressStaking(msg.sender) == false,
            "Unstake your NFT First"
        );

        stakers[msg.sender] = Staker(
            _tokenId,
            block.number,
            block.timestamp,
            1,
            block.timestamp + TIMELOCK
        );
        nft.safeTransferFrom(msg.sender, address(this), _tokenId, 1, "0x00");
    }

    function unstake() public {
        require(
            stakers[msg.sender].unlockPeriod <= block.timestamp,
            "Unable to unstake within locked period"
        );
        nft.safeTransferFrom(
            address(this),
            msg.sender,
            stakers[msg.sender].tokenId,
            stakers[msg.sender].amount,
            "0x00"
        );
        // calculate rewards
        // User should earn .001 ETH every block while NFT is staked
        uint256 rewards = checkRewards(msg.sender); //((block.number - stakers[msg.sender].stakedBlockNumber) * 1000000000000000);
        delete stakers[msg.sender];

        // for simplicity, after the user unstakes his NFT,
        // we will automatically and immediately transfer the ETH rewards to the user
        // this of course assumes that the contract has the avaialble ETH :)
        payable(msg.sender).transfer(rewards);
    }

    function checkRewards(address _address) public view returns (uint256) {
        uint256 rewards = ((block.number -
            stakers[_address].stakedBlockNumber) * 1000000000000000);
        console.log(block.number);
        console.log(stakers[_address].stakedBlockNumber);
        console.log(rewards);
        return rewards;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }
}
