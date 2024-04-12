// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";

contract MyDXToken is ERC20 {
    // price expressed as how much an ether can buy
    uint256 public unitsOneEthCanBuy = 10;
    // the owner of the token
    address public tokenOwner;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        // address of the token owner
        tokenOwner = msg.sender;
        // ERC20 tokens have 18 decimals
        // number of tokens minted = n * 10^18
        uint256 n = 1000;
        _mint(msg.sender, n * 10**uint256(decimals()));
    }
}
