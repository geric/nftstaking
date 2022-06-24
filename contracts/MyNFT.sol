// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC1155, Ownable {
    uint256 maxSupply;
    uint256 public nftIdCounter;
    address public treasuryAddress;

    mapping (uint256 => string) private _uris;

    constructor(uint _maxSupply) ERC1155("https://api.example.com/tokens/{id}") {
        nftIdCounter = 0;
        treasuryAddress = msg.sender;
        maxSupply = _maxSupply;
    }

    function uri(uint256 _tokenId) override public view returns (string memory) {
        return(_uris[_tokenId]);
    }

    function setTokenUri (uint256 _tokenId, string memory _uri) public onlyOwner {
        _uris[_tokenId] = _uri;
    }

    function mint(string memory _uri) public onlyOwner {
        _mint(treasuryAddress, nftIdCounter, maxSupply, "");
        setTokenUri(nftIdCounter, _uri);
        nftIdCounter += 1;
    }

    function updateTreasury(address _treasuryAddress) public onlyOwner {
        treasuryAddress = _treasuryAddress;
    }
}
