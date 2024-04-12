pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ZkSyncDiceGame003 is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    uint256 private constant MIN_BET = 0.01 ether;
    uint256 private constant MAX_BET = 0.1 ether;
    uint256 private constant AUTO_WITHDRAW_THRESHOLD = 0.3 ether;
    uint256 private constant AUTO_WITHDRAW_AMOUNT = 0.2 ether;
    uint8 private constant WINNING_PROBABILITY = 50;
    uint256 private constant PRIZE_MULTIPLIER = 195;
    uint256 private constant PRIZE_DIVISOR = 100;
    
    constructor() Ownable(msg.sender) {
    }
    
    event PlayEvent(address indexed player, uint256 amount, bool isWin, uint256 prize);
    event WithdrawEvent(address indexed recipient, uint256 amount);
    event FailureEvent(address indexed player, uint256 amount, string reason);
    
    function play() internal {
        if (msg.value < MIN_BET || msg.value > MAX_BET) {
            emit FailureEvent(msg.sender, msg.value, "Bet amount must be within the allowed range");
            return;
        }
        
        uint256 balance = address(this).balance;
        if (balance < msg.value) {
            emit FailureEvent(msg.sender, msg.value, "Insufficient contract balance");
            return;
        }
    
        uint256 randomNumber = generateRandomNumber();
    
        if (randomNumber <= WINNING_PROBABILITY) {
            uint256 prizeAmount = msg.value.mul(PRIZE_MULTIPLIER).div(PRIZE_DIVISOR);
            if (!payable(msg.sender).send(prizeAmount)) {
                emit FailureEvent(msg.sender, msg.value, "Failed to send prize");
                return;
            }
            emit PlayEvent(msg.sender, msg.value, true, prizeAmount);
        
            bytes memory winningResult = abi.encodeWithSignature("winningResult()", "You won!");
            (bool success, ) = msg.sender.call{value: 0}(winningResult);
            require(success, "Failed to send winning result");

        } else {
            emit PlayEvent(msg.sender, msg.value, false, 0);
        bytes memory losingResult = abi.encodeWithSignature("losingResult()", "You lost!");
        (bool success, ) = msg.sender.call{value: 0}(losingResult);
        require(success, "Failed to send losing result");
        }
    
        if (balance >= AUTO_WITHDRAW_THRESHOLD) {
            if (!payable(owner()).send(AUTO_WITHDRAW_AMOUNT)) {
                emit FailureEvent(owner(), AUTO_WITHDRAW_AMOUNT, "Failed to auto withdraw");
            } else {
                emit WithdrawEvent(owner(), AUTO_WITHDRAW_AMOUNT);
            }
        }
    }
    
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        if (!payable(owner()).send(balance)) {
            emit FailureEvent(owner(), balance, "Failed to withdraw");
        } else {
            emit WithdrawEvent(owner(), balance);
        }
    }
    
    function generateRandomNumber() private view returns (uint256) {
         // Use keccak256 of a combination of unpredictable elements
         bytes32 hash = keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp, msg.sender));

            // Use a more secure way to get randomness (explained below)
            uint256 randomNumber = uint256(hash) % 100 + 1;

            return randomNumber;
    }

    
    receive() external payable {
        if (msg.value % 1e16 != 0) {
            // If the deposited amount has more than 2 decimal places (1e16 wei), simply accept the deposit without playing the game
            return;
        }
        play();
    }
    
    fallback() external payable {
        if (msg.value % 1e16 != 0) {
            // If the deposited amount has more than 2 decimal places (1e16 wei), simply accept the deposit without playing the game
            return;
        }
        play();
    }
}