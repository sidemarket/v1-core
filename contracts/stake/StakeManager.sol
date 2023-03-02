// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.9;

import "./../interfaces/IERC20Minimal.sol";

contract StakeManager {

    IERC20Minimal internal token;

    uint256 public funds;

    struct Stake {
        uint256 balance;
        uint256 creationTimestamp;
        uint256 releaseTimestamp;
    }

    mapping(address => Stake[]) public stakes;
    mapping(address => uint256) public votingPower;

    constructor(address tokenAddress) {
        token = IERC20Minimal(tokenAddress);
    }

    function replenish(uint256 amount) external {
        require(token.transferFrom(msg.sender, address(this), amount), "Replenish transfer failed");

        funds += amount;
    }

    function stake(uint256 amount) external {
        require(token.transferFrom(msg.sender, address(this), amount), "Staking transfer failed");
        require(amount > 0, "Amount can't be 0");

        stakes[msg.sender].push(Stake(amount, block.timestamp, 0));
        votingPower[msg.sender] += amount;
    }

    function unstake(uint256 index) external {
        require(stakes[msg.sender][index].balance >= 0, "The index is not available");

        if(stakes[msg.sender][index].releaseTimestamp > 0) {
            _transferStake(stakes[msg.sender][index]);
        } else {
            _scheduleStake(stakes[msg.sender]);
        }
    }

    function _transferStake(uint256 index) internal {
        uint256 balance = stakes[msg.sender][index].balance;
        uint256 reward = _calculateReward(balance, stakes[msg.sender][index].releaseTimestamp - stakes[msg.sender][index].creationTimestamp);

        votingPower[msg.sender] -= balance;
        delete stakes[msg.sender][index];

        if(funds >= reward) {
            funds -= reward;
            require(token.transfer(msg.sender, balance + reward), "Unstake with reward failed");
        } else {
            require(token.transfer(msg.sender, balance), "Unstake failed");
        }
    }

    function _scheduleStake(uint256 index) internal {
        stakes[msg.sender][index].releaseTimestamp = block.timestamp + 21 days;
    }

    function _calculateReward(uint256 balance, uint256 time) internal pure returns(uint256) {
        return balance + (time * (balance * 6 / 100) / 365 days);
    }

}