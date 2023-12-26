// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConvertor {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        // whenever we interact with a contract we always need the address and the ABI
        // Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price * 1e10); // always ensure to use correct units to interact with the contract
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // 1 ETH ?
        // 2000_000000000000000000
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18; // -> number bada ho jaaega isliye divide kar rahe
        return ethAmountInUsd;
    }

    function getVersion() internal view returns (uint256) {
        return
            AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)
                .version();
    }
}
