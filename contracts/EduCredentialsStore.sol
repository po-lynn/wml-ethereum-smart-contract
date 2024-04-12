// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import "./token.sol";

contract EduCredentialsStore {
    //---store the hash of the strings and their
    // corresponding block number---
    // key is bytes32 and val is uint
    mapping(bytes32 => uint256) private proofs;
    address owner = msg.sender;

    MyToken token = MyToken(payable(address(0x37cbDC219164cd9bF0b111F1372eB1B4C76e0E04)));

    //---define an event
    event Result(address from, string document, uint256 blockNumber);

    //==========================================
    // return the token balance in the contract
    //==========================================
    function getBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    //--------------------------------------------------
    // Store a proof of existence in the contract state
    //--------------------------------------------------

    function storeProof(bytes32 proof) private {
        // use the hash as the key
        proofs[proof] = block.number;
    }

    //----------------------------------------------
    // Calculate and store the proof for a document
    //----------------------------------------------
    function storeEduCredentials(string calldata document) external {
        require(
            msg.sender == owner,
            "Only the owner of contract can store the credentials"
        );
        // call storeProof() with the hash of the string
        storeProof(proofFor(document));
    }

    //--------------------------------------------
    // Helper function to get a document's sha256
    //--------------------------------------------
    // Takes in a string and returns the hash of the
    // string
    function proofFor(string calldata document) private pure returns (bytes32) {
        // converts the string into bytes array and
        // then hash it
        return sha256(bytes(document));
    }

    //-----------------------------------------------
    // Check if a document has been saved previously
    //-----------------------------------------------
    function checkEduCredentials(string calldata document)
        public
        payable
        returns (uint256)
    {
        // use the hash of the string and check the
        // proofs mapping object
        //  require(msg.value == 1000 wei,"This call requires 1000 wei");
        // use the hash of the string and check
        // the proofs mapping object, then fire the event

        // msg.sender is the account that calls the
        // token contract
        // go and check the allowance set by the caller
        uint256 approvedAmt = token.allowance(msg.sender, address(this));

        // the amount is based on the base unit in the
        // token
        uint256 requiredAmt = 1000;
        // ensure the caller has enough tokens approved
        // to pay to the contract
        require(
            approvedAmt >= requiredAmt,
            "Token allowance approved is less than what you   need to pay"
        );
        // transfer the tokens from sender to token contract
        token.transferFrom(msg.sender, payable(address(this)), requiredAmt);
        // use the hash of the string and check the proofs
        // mapping object
        return proofs[proofFor(document)];

        //  emit Result(msg.sender, document, proofs[proofFor(document)]);
        //  return proofs[proofFor(document)];
    }

    function cashOut() public {
        require(
            msg.sender == owner,
            "Only the owner of contract can cash out!"
        );
        payable(owner).transfer(address(this).balance);
    }

    /* self-destruct function */
    function kill() public {
        require(msg.sender == owner, "Only owner can kill this contract");
        selfdestruct(payable(owner));
    }
}
//https://codebeautify.org/json-to-base64-converter
// {
//   "id": "1234567",
//   "result": {
//     "math": "A",
//     "science": "B",
//     "english": "A"
//   }
// }

//ewogICJpZCI6ICIxMjM0NTY3IiwKICAicmVzdWx0IjogewogICAgIm1hdGgiOiAiQSIsCiAgICAic2NpZW5jZSI6ICJCIiwKICAgICJlbmdsaXNoIjogIkEiCiAgfQp9