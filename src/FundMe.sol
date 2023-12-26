// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConvertor} from "./PriceConvertor.sol"; 
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    using PriceConvertor for uint256;
    uint256 public minimumUsd = 5e18;

    address[] private s_funders;
    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;

    address private immutable i_owner;
    uint256 public constant MINIMUM_USD = 5*10**18;
    AggregatorV3Interface private s_priceFeed; 
    // s_priceFeed depend on the chain we are on

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        // msg.value.getConversionRate();
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "failed due to insufficient ETH"); 
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;  
    }

    function getVersion() public view returns(uint256) {
        return s_priceFeed.version();
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for(uint256 i = 0; i < fundersLength; i++) {
            address funder = s_funders[i];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);

        // call
        (bool flag, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(flag, "Transaction failed");
    }

    function withdraw() public onlyOwner {      
        for(uint256 i = 0; i < s_funders.length; i++) {
            address funder = s_funders[i];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);

        // // transfer
        // payable(msg.sender).transfer(address(this).balance);

        // // send
        // bool flag = payable(msg.sender).send(address(this).balance);
        // require(flag, "Transaction failed");

        // call
        (bool flag, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(flag, "Transaction failed");
    }

    modifier onlyOwner(){
        require(msg.sender == i_owner, "Sender is not owner");
        _;
    }

    receive() external payable { 
        fund();
    }

    fallback() external payable { 
        fund();
    }

    // View / Pure functions (Getters)
    function getAddressToAmountFunded(address fundingAddress) external view returns(uint256){
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns(address) {
        return s_funders[index];
    }

    function getOwner() external view returns(address){
        return i_owner;
    }
}