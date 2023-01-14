const { network } = require("hardhat");
const { developmentChains, networkConfig } = require("../helper-hardhat-config");

module.exports = async function({ deployments, getNamedAccounts }) {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;

    let ethUsdPriceFeedAddress;
    if(developmentChains.includes(network.name)) {
        const aggregator = await deployments.get("MockV3Aggregator");
        ethUsdPriceFeedAddress = aggregator.address;
    } else {
        ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeedAddress"];
    }
    log("---------------------------------------------");
    log("deploying FundMe and waiting for confirmation...");
    const fundMe = await deploy("FundMe", {
        from: deployer,
        args: [ethUsdPriceFeedAddress],
        log: true,
    });
    log(`FundMe deployed successfully at ${fundMe.address}`);

    // verification, if the contract is deployed to a testnet or mainnet
}

module.exports.tags = ["all", "fundme"];