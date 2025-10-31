// src/config.js
// Configuration file for DAO contract deployment and Alchemy RPC settings

/**
 * DAO Contract Address on Ethereum Sepolia Testnet
 * This address is where your DAO.sol contract is deployed
 * Replace with your actual deployed contract address
 */
export const DAO_CONTRACT_ADDRESS = "0xDaa318b6B49c43094BE7bf85856FC65ceE36F5C0"; // Enhanced DAO contract

/**
 * Alchemy API Configuration
 * Alchemy provides enterprise-grade Ethereum infrastructure
 * Sign up at https://dashboard.alchemy.com/ to get your API key
 */
export const ALCHEMY_API_KEY = import.meta.env.VITE_ALCHEMY_API_KEY || "your-alchemy-api-key-here";

/**
 * Alchemy RPC Endpoint for Sepolia Testnet
 * This endpoint allows us to read blockchain data without requiring wallet connection
 */
export const ALCHEMY_RPC_URL = `https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY}`;

/**
 * Network Configuration
 */
export const NETWORK_CONFIG = {
  chainId: 11155111, // Sepolia testnet chain ID
  name: "Sepolia",
  rpcUrl: ALCHEMY_RPC_URL,
  blockExplorer: "https://sepolia.etherscan.io"
};

/**
 * Contract Event Topics
 * These are used for filtering specific events from the blockchain
 */
export const EVENT_TOPICS = {
  PROPOSAL_CREATED: "ProposalCreated(uint256,string,address,uint256)"
};
