// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";

contract DecentralizedExchange {
    address public owner;
    uint256 public feePercentage; // Fee percentage charged for trades
    mapping(address => uint256) public balances;

    event Trade(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 timestamp
    );

    constructor() {
        owner = msg.sender;
        feePercentage = 1; // 1% trading fee
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function setTradingFee(uint256 _feePercentage) public onlyOwner {
        feePercentage = _feePercentage;
    }

    function depositToken(address token, uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(
            IERC20(token).transferFrom(msg.sender, address(this), amount),
            "Token transfer failed"
        );
        balances[msg.sender] += amount;
    }

    function withdrawToken(address token, uint256 amount) public {
        require(
            amount > 0 && amount <= balances[msg.sender],
            "Invalid withdrawal amount"
        );
        balances[msg.sender] -= amount;
        require(
            IERC20(token).transfer(msg.sender, amount),
            "Token transfer failed"
        );
    }

    function trade(address token, uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(
            balances[msg.sender] >= amount,
            "Insufficient balance for trading"
        );
        uint256 fee = (amount * feePercentage) / 100;
        uint256 tradeAmount = amount - fee;
        balances[msg.sender] -= amount;
        balances[owner] += fee;
        balances[msg.sender] += tradeAmount;
        emit Trade(msg.sender, token, tradeAmount, block.timestamp);
    }
}

// Interface for ERC-20 token
interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);
}
