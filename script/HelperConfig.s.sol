// 1. Deploy mocks when we are on a local anvil chain
// 2. Keep track of contract address across different chains
// Sepolia ETH/USD
// Mainnet ETH/USD
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
    // if we are on local anvil, we deploy mocks
    // otherwise we get the existing address from the live network

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    NetworkConfig public activeNetworkConfig ;// to see we are on which network currently

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if(block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        }
        else {
            activeNetworkConfig = getOrCreateAnvilEthCofig();
        }
    }

    function getSepoliaEthConfig() public pure returns(NetworkConfig memory){
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return sepoliaConfig;
    }

    function getOrCreateAnvilEthCofig() public returns(NetworkConfig memory) {
        // price feed address 
        // we are checking this because if we dont check this then we are deploying a priceFeed everytime getAnvilEthConfig is called
        // but if the address is not default i.e address(0) that means we have set it 
        if(activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }


        // 1. Deploy the mocks
        // 2. Return the mock address

        vm.startBroadcast();
        // instead of passing numbers in the bracket we can store them in variables so that we know what these numbers are
        // MockV3Aggregator mockPriceFeed = new MockV3Aggregator(8, 2000e8);
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });

        return anvilConfig;
    }
}