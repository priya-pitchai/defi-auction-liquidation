// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract PriceOracle {

    AggregatorV3Interface private immutable ethUsdPriceFeed;

    constructor(address _priceFeedContract) {

            ethUsdPriceFeed = AggregatorV3Interface(_priceFeedContract);
    }

    function getLatestPrice() public view returns(int256) {
        (, int256 price, , , ) = ethUsdPriceFeed.latestRoundData();
        require(price > 0, "PriceOracle: Invalid price");
        return price;
    }

}