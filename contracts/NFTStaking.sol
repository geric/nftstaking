// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "hardhat/console.sol";

contract NFTStaking {
    IERC1155 public immutable nft;

    //TODO staking period

    // we limit that only 1 NFT can be staked per address
    // based on the requirements defined, the amount of staked NFT does not matter
    struct Staker {
        uint256 tokenId;
        uint256 stakedBlockNumber;
        uint256 stakedTime;
        uint256 amount;
    }

    mapping(address => Staker) public stakers;

    constructor(address _nft) {
        nft = IERC1155(_nft);
    }

    function isAddressStaking(address addr) public view returns(bool) {
        if (stakers[addr].stakedBlockNumber != 0) {
            return true;
        }
        return false;
    }

    function stake(uint256 _tokenId) public {
        // check if user is already staking
        require(isAddressStaking(msg.sender) == false, "Unstake your NFT First");

        stakers[msg.sender] = Staker(_tokenId, block.number , block.timestamp, 1);
        nft.safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId,
            1,
            "0x00"
        );
    }

     function unstake() public {
        nft.safeTransferFrom(address(this), msg.sender, stakers[msg.sender].tokenId, stakers[msg.sender].amount, "0x00");
        // calculate rewards
        // User should earn .001 ETH every block while NFT is staked
        uint256 rewards = ((block.number - stakers[msg.sender].stakedBlockNumber) * 1000000000000000000);
        console.log(rewards);
        delete stakers[msg.sender];
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
