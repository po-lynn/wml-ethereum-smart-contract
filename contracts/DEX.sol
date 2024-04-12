// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";

contract DEX {
    ERC20 WML_token;
    ERC20 LWM_token;

    //=======================
    // constructor of the DEX
    //=======================
    constructor() payable {
        //---be sure to replace the following addresses with your own---
        WML_token = ERC20(address(0xE90CEb5055eC4949b29e74Ea5628fA497Baa9E28));
        LWM_token = ERC20(address(0xb7809BA94AA584Bd968fFE6FC6e1CB829Ce2F4CA));
    }

    //===================================
    // find the tokens balance in the DEX
    //===================================
    function getBalance() public view returns (uint256, uint256) {
        return (
            WML_token.balanceOf(address(this)),
            LWM_token.balanceOf(address(this))
        );
    }

    function compareStrings(string memory a, string memory b)
        private
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    //================
    // exchange tokens
    //================
    function exchange(
        string calldata from_token,
        string calldata to_token,
        uint256 amount
    ) public {
        // Remember that all transactions are based on the smallest units in the token
        //=========
        // CHECK #1
        //=========
        // ensure the amount to convert is > 0
        require(amount > 0, "You need to convert at least some tokens");
        // record the token contracts to convert from and to
        ERC20 from; // the tokens to convert from
        ERC20 to; // the tokens to convert to
        if (compareStrings(from_token, "WML")) {
            from = WML_token;
        } else {
            from = LWM_token;
        }
        if (compareStrings(to_token, "WML")) {
            to = WML_token;
        } else {
            to = LWM_token;
        }
        // obtain the allowance set by the sender to send to this DEX
        uint256 approvedAmt;
        approvedAmt = from.allowance(msg.sender, address(this));
        //=========
        // CHECK #2
        //=========
        // ensure the sender has enough tokens approved to convert

        require(
            approvedAmt >= amount,
            "Token allowance is less than what you want to convert"
        );
        //=========
        // CHECK #3
        //=========
        // get the balance of tokens (that the sender wants to convert to)in the pool
        uint256 dexBalance = to.balanceOf(address(this));
        // need to check that DEX has enough "to" token to send to sender
        require(amount <= dexBalance, "Sorry, not enough tokens in the DEX");
        // transfer the tokens from sender to DEX
        from.transferFrom(msg.sender, address(this), amount);
        // transfer the exchanged tokens to the sender
        to.transfer(msg.sender, amount);
    }
}
