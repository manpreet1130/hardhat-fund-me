// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getConversion(uint ethAmount, AggregatorV3Interface priceFeed) internal view returns(uint) {
        (, int price,,,) = priceFeed.latestRoundData();
        price = price * 10 ** 10; // AggregatorV3Interface returns value with 8 decimals (2000.00000000)
        return (ethAmount * uint(price)) / (10 ** 18);
    }
}