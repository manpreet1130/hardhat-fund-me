// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint;

    address[] private s_funders;
    mapping(address => uint) private s_funderToFunding;
    address private immutable i_owner;

    uint private constant MINIMUM_USD = 50 * 10 ** 18; // minimum usd: $50

    AggregatorV3Interface private priceFeed;

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    modifier onlyOwner {
        if(msg.sender != i_owner) {
            revert("not a contract owner...");
        }
        _;
    }

    function fund() public payable {
        if(msg.value.getConversion(priceFeed) < MINIMUM_USD) {
            revert("more ETH required...");
        }
        s_funders.push(msg.sender);
        s_funderToFunding[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        address[] memory funders = s_funders;

        for(uint funderIndex = 0;funderIndex < funders.length;funderIndex++) {
            address funder = funders[funderIndex];
            s_funderToFunding[funder] = 0;
        }
        s_funders = new address[](0);

        (bool success, ) = i_owner.call{
            value: address(this).balance
        }("");
        require(success, "something went wrong while withdrawal...");
    }

    function getFunderByIndex(uint index) public view returns(address) {
        return s_funders[index];
    }

    function getFundingByFunder(address funder) public view returns(uint) {
        return s_funderToFunding[funder];
    }

    function getPriceFeed() public view returns(AggregatorV3Interface) {
        return priceFeed;
    }

    function getOwner() public view returns(address) {
        return i_owner;
    }

}