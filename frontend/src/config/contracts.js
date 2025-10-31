export const CONTRACTS = {
  GovernanceToken: {
    address: "0x5FbDB2315678afecb367f032d93F642f64180aa3",
    abi: [], // Will be populated by build process
  },
  DAO: {
    address: "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0",
    abi: [], // Will be populated by build process
  },
  Treasury: {
    address: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
    abi: [], // Will be populated by build process
  },
};

export const NETWORK_CONFIG = {
  chainId: 31337,
  name: "localhost",
  rpcUrl: "http://127.0.0.1:8545",
  explorerUrl: "http://localhost:8545",
};

export const CONTRACT_ADDRESSES = {
  GovernanceToken: "0x5FbDB2315678afecb367f032d93F642f64180aa3",
  DAO: "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0",
  Treasury: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
};

// Legacy exports for backward compatibility
export const LOCALHOST_ADDRESSES = {
  GOVERNANCE_TOKEN: "0x5FbDB2315678afecb367f032d93F642f64180aa3",
  DAO: "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0",
  TREASURY: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
};

export const SEPOLIA_ADDRESSES = {
  GOVERNANCE_TOKEN: "0x742d35Cc6661C0532a2135cfEAbE60a9A4E60B3a",
  DAO: "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0", 
  TREASURY: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
};

// Governance parameters for proposal creation
export const GOVERNANCE_PARAMS = {
  VOTING_DELAY: 1, // 1 block delay before voting starts
  VOTING_PERIOD: 50400, // ~1 week in blocks (assuming 12s per block)
  PROPOSAL_THRESHOLD: "100000000000000000000", // 100 tokens minimum to create proposal
  QUORUM_PERCENTAGE: 4, // 4% quorum required
};
