import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { sepolia } from 'wagmi/chains';
import { http } from 'viem';

// Define localhost chain for development
const localhost = {
  id: 31337,
  name: 'Localhost',
  network: 'localhost',
  nativeCurrency: {
    decimals: 18,
    name: 'Ether',
    symbol: 'ETH',
  },
  rpcUrls: {
    default: { 
      http: ['http://127.0.0.1:8545'],
    },
    public: {
      http: ['http://127.0.0.1:8545'],
    }
  },
  contracts: {
    multicall3: {
      address: '0xca11bde05977b3631167028862be2a173976ca11',
      blockCreated: 0,
    },
  },
};

// Get WalletConnect project ID with fallback
const getWalletConnectProjectId = () => {
  const projectId = import.meta.env.VITE_WALLETCONNECT_PROJECT_ID;
  
  if (!projectId || projectId === 'YOUR_PROJECT_ID' || projectId.trim() === '') {
    console.log('[DVote] WalletConnect disabled - no project ID configured');
    return null;
  }
  
  return projectId;
};

// Configure wagmi with proper error handling
const createConfig = () => {
  try {
    const projectId = getWalletConnectProjectId();
    
    // Define chains with Sepolia using public RPC
    const chains = [sepolia, localhost];
    
    return getDefaultConfig({
      appName: 'DVote DAO Governance',
      projectId: projectId || '',
      chains,
      transports: {
        [sepolia.id]: http('https://ethereum-sepolia-rpc.publicnode.com'), // Using public RPC
        [localhost.id]: http('http://127.0.0.1:8545'),
      },
      ssr: false,
    });

  } catch (error) {
    console.warn('[DVote] Failed to initialize wallet configuration:', error.message);
    return getDefaultConfig({
      appName: 'DVote DAO Governance',
      projectId: '',
      chains: [sepolia, localhost],
      transports: {
        [sepolia.id]: http('https://ethereum-sepolia-rpc.publicnode.com'),
        [localhost.id]: http('http://127.0.0.1:8545'),
      },
      ssr: false,
    });
  }
};

export const config = createConfig();
