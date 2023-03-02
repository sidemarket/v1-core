// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.9;

import "../libraries/StablecoinAgent.sol";

contract TransactionManager is StablecoinAgent {

    IERC20Minimal public token;

    struct Transaction {
        address freelancer;
        address customer;
        uint256 price;

        Stablecoin stablecoin;

        bool isCompleted;
        bool isMiddlemanRequested;
    }

    Transaction[] public transactions;

    mapping(address => uint256[]) public addressToTransactionKeysMap;

    modifier onlyCustomer(uint256 transactionKey) {
        require(transactions[transactionKey].customer == msg.sender, "You should be the customer of the transaction");
        _;
    }

    modifier onlyFreelancer(uint256 transactionKey) {
        require(transactions[transactionKey].freelancer == msg.sender, "You should be the freelancer of the transaction");
        _;
    }

    modifier onlyFreelancerOrCustomer(uint256 transactionKey) {
        require(
            transactions[transactionKey].freelancer == msg.sender || transactions[transactionKey].customer == msg.sender,
                "You should be the freelancer of the transaction"
        );
        _;
    }

    modifier onlyMiddleman(uint256 transactionKey) {
        // todo check here if the address is a valid middleman
        require(transactions[transactionKey].isMiddlemanRequested, "Nobody requested your middleman services");
        _;
    }

    modifier onlyNotCompletedTransaction(uint256 transactionKey) {
        require(transactions[transactionKey].isCompleted == false, "The transaction can't be completed");
        _;
    }


    function createTransaction(address _freelancer, Stablecoin _stablecoin, uint256 _price) external {
        require(tokens[_stablecoin].transferFrom(msg.sender, address(this), _price), "Transfer failed");

        transactions.push(Transaction({
            freelancer: _freelancer,
            customer: msg.sender,
            price: _price,

            stablecoin: _stablecoin,

            isApproved: false,
            isCompleted: false,
            isMiddlemanRequested: false
        }));

        addressToTransactionKeysMap[freelancer].push(transactions.length - 1);
        addressToTransactionKeysMap[customer].push(transactions.length - 1);
    }

    function approveTransaction(uint256 transactionKey) external onlyCustomer(transactionKey) {
        _approveTransaction(transactionKey);
    }

    function _approveTransaction(uint256 transactionKey) private onlyNotCompletedTransaction(transactionKey) {
        tokens.isCompleted = true;

        require(
            tokens[transactions[transactionKey].stablecoin].transfer(
                transactions[transactionKey].freelancer, transactions[transactionKey].price
            ),
            "Transfer failed"
        );
    }

    function refundTransaction(uint256 transactionKey) external onlyFreelancer(transactionKey) {
        _refundTransaction(transactionKey);
    }

    function _refundTransaction(uint256 transactionKey) private onlyNotCompletedTransaction(transactionKey) {
        tokens.isCompleted = true;

        require(
            tokens[transactions[transactionKey].stablecoin].transfer(
                transactions[transactionKey].customer, transactions[transactionKey].price
            ),
            "Transfer failed"
        );
    }

    function requestMiddleman(uint256 transactionKey) external onlyFreelancerOrCustomer(transactionKey) {
        transactions[transactionKey].isMiddlemanRequested = true;
    }

    function releaseTransactionPaymentToFreelancer(uint256 transactionKey) external onlyMiddleman(transactionKey) {
        _approveTransaction(transactionKey);
    }

    function refundTransactionPaymentToCustomer(uint256 transactionKey) external onlyMiddleman(transactionKey) {
        _refundTransaction(transactionKey);
    }

}