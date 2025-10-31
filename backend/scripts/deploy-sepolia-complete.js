const hre = require("hardhat");
const fs = require("fs");

async function main() {
  console.log("🌐 DVote Sepolia Deployment");
  console.log("===========================");

  // Check network
  const network = hre.network.name;
  if (network !== "sepolia") {
    throw new Error("This script is for Sepolia network only!");
  }

  // Get deployer
  const [deployer] = await hre.ethers.getSigners();
  console.log(`🚀 Deploying from: ${deployer.address}`);
  
  // Check balance
  const balance = await hre.ethers.provider.getBalance(deployer.address);
  console.log(`💰 Balance: ${hre.ethers.formatEther(balance)} ETH`);
  
  if (balance < hre.ethers.parseEther("0.1")) {
    throw new Error("Insufficient ETH for deployment. Get more from Sepolia faucet!");
  }

  // Deployment addresses to track
  const deploymentAddresses = {
    network: "sepolia",
    chainId: 11155111,
    deployer: deployer.address,
    timestamp: new Date().toISOString()
  };

  try {
    // 1. Deploy GovernanceToken
    console.log("\n🪙 Deploying GovernanceToken...");
    const GovernanceToken = await hre.ethers.getContractFactory("GovernanceToken");
    const token = await GovernanceToken.deploy("DVote Token", "DVT", deployer.address);
    await token.waitForDeployment();
    
    const tokenAddress = await token.getAddress();
    deploymentAddresses.GovernanceToken = tokenAddress;
    console.log(`✅ GovernanceToken deployed: ${tokenAddress}`);

    // 2. Deploy Treasury
    console.log("\n💰 Deploying Treasury...");
    const Treasury = await hre.ethers.getContractFactory("Treasury");
    const treasury = await Treasury.deploy();
    await treasury.waitForDeployment();
    
    const treasuryAddress = await treasury.getAddress();
    deploymentAddresses.Treasury = treasuryAddress;
    console.log(`✅ Treasury deployed: ${treasuryAddress}`);

    // 3. Deploy DAO
    console.log("\n🏛️ Deploying DAO...");
    const DAO = await hre.ethers.getContractFactory("DAO");
    const dao = await DAO.deploy(tokenAddress, treasuryAddress, deployer.address);
    await dao.waitForDeployment();
    
    const daoAddress = await dao.getAddress();
    deploymentAddresses.DAO = daoAddress;
    console.log(`✅ DAO deployed: ${daoAddress}`);

    // 4. Configure contracts
    console.log("\n⚙️ Configuring contracts...");
    
    // Transfer treasury ownership to DAO
    console.log("📝 Transferring treasury ownership to DAO...");
    const transferTx = await treasury.transferOwnership(daoAddress);
    await transferTx.wait();
    console.log("✅ Treasury ownership transferred");

    // Set allowed targets in DAO
    console.log("📝 Setting allowed targets...");
    const allowZeroTx = await dao.setAllowedTarget("0x0000000000000000000000000000000000000000", true);
    await allowZeroTx.wait();
    
    const allowTreasuryTx = await dao.setAllowedTarget(treasuryAddress, true);
    await allowTreasuryTx.wait();
    console.log("✅ Allowed targets configured");

    // 5. Mint initial tokens and delegate
    console.log("\n🪙 Minting initial tokens...");
    const mintAmount = hre.ethers.parseEther("1000000"); // 1M tokens
    const mintTx = await token.mint(deployer.address, mintAmount);
    await mintTx.wait();
    
    // Delegate voting power to self
    const delegateTx = await token.delegate(deployer.address);
    await delegateTx.wait();
    
    console.log(`✅ Minted ${hre.ethers.formatEther(mintAmount)} DVT tokens`);
    console.log("✅ Delegated voting power to deployer");

    // 6. Fund treasury with some ETH
    console.log("\n💰 Funding treasury...");
    const fundAmount = hre.ethers.parseEther("0.01"); // Small amount for testing
    const fundTx = await deployer.sendTransaction({
      to: treasuryAddress,
      value: fundAmount
    });
    await fundTx.wait();
    console.log(`✅ Funded treasury with ${hre.ethers.formatEther(fundAmount)} ETH`);

    // 7. Save deployment info
    console.log("\n💾 Saving deployment info...");
    
    // Save to deployments directory
    const deploymentsDir = "./deployments";
    if (!fs.existsSync(deploymentsDir)) {
      fs.mkdirSync(deploymentsDir);
    }
    
    fs.writeFileSync(
      `${deploymentsDir}/sepolia.json`,
      JSON.stringify(deploymentAddresses, null, 2)
    );

    // Save to root deployment-info.json (for frontend)
    const rootDeploymentInfo = {
      network: "sepolia",
      ...deploymentAddresses
    };
    
    fs.writeFileSync(
      "../deployment-info.json",
      JSON.stringify(rootDeploymentInfo, null, 2)
    );

    // 8. Verify contracts (if Etherscan API key is available)
    if (process.env.ETHERSCAN_API_KEY) {
      console.log("\n🔍 Verifying contracts on Etherscan...");
      
      try {
        await hre.run("verify:verify", {
          address: tokenAddress,
          constructorArguments: ["DVote Token", "DVT", deployer.address],
        });
        console.log("✅ GovernanceToken verified");
      } catch (error) {
        console.log("⚠️ Token verification failed:", error.message);
      }

      try {
        await hre.run("verify:verify", {
          address: treasuryAddress,
          constructorArguments: [],
        });
        console.log("✅ Treasury verified");
      } catch (error) {
        console.log("⚠️ Treasury verification failed:", error.message);
      }

      try {
        await hre.run("verify:verify", {
          address: daoAddress,
          constructorArguments: [tokenAddress, treasuryAddress, deployer.address],
        });
        console.log("✅ DAO verified");
      } catch (error) {
        console.log("⚠️ DAO verification failed:", error.message);
      }
    }

    // 9. Display summary
    console.log("\n🎉 DEPLOYMENT SUCCESSFUL!");
    console.log("========================");
    console.log(`🌐 Network: Sepolia Testnet`);
    console.log(`🪙 GovernanceToken: ${tokenAddress}`);
    console.log(`💰 Treasury: ${treasuryAddress}`);
    console.log(`🏛️ DAO: ${daoAddress}`);
    console.log(`👤 Deployer: ${deployer.address}`);
    console.log(`💳 Deployer tokens: 1,000,000 DVT`);
    console.log(`🏦 Treasury balance: 0.01 ETH`);
    
    console.log("\n📱 Next Steps:");
    console.log("1. Update your frontend to use Sepolia network");
    console.log("2. Switch MetaMask to Sepolia testnet");
    console.log("3. Import the deployer account to MetaMask (if needed)");
    console.log("4. Start creating proposals!");
    
    console.log("\n🔗 Etherscan Links:");
    console.log(`GovernanceToken: https://sepolia.etherscan.io/address/${tokenAddress}`);
    console.log(`Treasury: https://sepolia.etherscan.io/address/${treasuryAddress}`);
    console.log(`DAO: https://sepolia.etherscan.io/address/${daoAddress}`);

  } catch (error) {
    console.error("\n❌ Deployment failed:", error.message);
    throw error;
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
