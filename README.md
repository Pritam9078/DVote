# 🗳️ DVote - Decentralized Governance Platform

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Built with React](https://img.shields.io/badge/Built%20with-React-61dafb.svg)](https://reactjs.org/)
[![Powered by Ethereum](https://img.shields.io/badge/Powered%20by-Ethereum-blue.svg)](https://ethereum.org/)

DVote is a fully on-chain decentralized autonomous organization (DAO) governance platform that enables community-driven decision making through blockchain technology. Built with modern Web3 technologies, DVote provides a complete solution for creating proposals, voting, treasury management, and community governance.

![DVote Logo](./frontend/public/dvote-logo.png)

## 🗳️ DVote DAO Governance Platform

A professional-grade decentralized autonomous organization (DAO) platform built on Ethereum, featuring token-based governance, proposal management, and treasury operations with custom branding and real IPFS integration.

## 🌟 Live Application

- **GitHub Repository**: https://github.com/Pritam9078/dvt
- **Frontend**: http://localhost:3000 (when running locally)
- **Backend API**: http://localhost:3001 (when running locally)

## 🚀 Key Features

### 🏛️ Advanced Governance System
- **Token-Based Voting**: DVT token holders participate in governance decisions
- **Multi-Type Proposals**: Specialized forms for different proposal types
- **Treasury Management**: Decentralized fund management and allocations
- **Real-Time Updates**: WebSocket-powered live proposal and voting updates
- **Custom Branding**: Integrated DVote logo throughout the application

### � Proposal Types with Custom Forms
- **Simple Polls**: Community sentiment with configurable voting options
- **Treasury Withdrawals**: ETH withdrawal with recipient validation and amount controls  
- **Token Transfers**: ERC-20 token transfers with contract address validation
- **Custom Actions**: Smart contract interactions with calldata input

### � Technical Infrastructure
- **IPFS Integration**: Real Pinata credentials for decentralized file storage
- **Multi-Network Support**: Localhost and Sepolia testnet compatibility
- **Modern UI/UX**: React 18 with Tailwind CSS and smooth animations
- **Web3 Integration**: Wagmi + RainbowKit for seamless wallet connections

## 📋 Smart Contract Addresses (Sepolia Testnet)

| Contract | Address | Explorer |
|----------|---------|----------|
| **GovernanceToken** | `0xD455dC84850597D0C3d79fbcdaAD277D67b6d78e` | [View on Etherscan](https://sepolia.etherscan.io/address/0xD455dC84850597D0C3d79fbcdaAD277D67b6d78e) |
| **DAO Contract** | `0x76be9202347f53ab19A19cF15aEbc2e09eE26B42` | [View on Etherscan](https://sepolia.etherscan.io/address/0x76be9202347f53ab19A19cF15aEbc2e09eE26B42) |
| **Treasury** | `0x98636BEF2dF2b43B6b17d6f27E17bAa427856e30` | [View on Etherscan](https://sepolia.etherscan.io/address/0x98636BEF2dF2b43B6b17d6f27E17bAa427856e30) |

## 🚀 Quick Start

### Prerequisites
- Node.js v16 or higher
- MetaMask browser extension
- Git

### Installation & Running

1. **Clone the repository**
```bash
git clone https://github.com/Pritam9078/DVote.git
cd DVote
```

2. **Install root dependencies**
```bash
npm install
```

3. **Install backend dependencies**
```bash
cd backend
npm install
cd ..
```

4. **Install frontend dependencies**
```bash
cd frontend
npm install
cd ..
```

5. **Start all services**
```bash
# Terminal 1: Start Hardhat blockchain node
npx hardhat node

# Terminal 2: Start backend server
cd backend && npm start

# Terminal 3: Start frontend development server
cd frontend && npm run dev
```

## 🌐 Access Points

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:3001
- **Blockchain RPC**: http://localhost:8545

## 🏗️ Project Structure

```
DVote/
├── frontend/          # React + Vite frontend
│   ├── src/
│   │   ├── components/    # React components
│   │   ├── pages/         # Page components
│   │   ├── services/      # API services
│   │   ├── config/        # Configuration files
│   │   └── utils/         # Utility functions
│   └── public/        # Static assets
├── backend/           # Node.js backend with API
│   ├── routes/        # API routes
│   ├── services/      # Business logic
│   ├── scripts/       # Deployment scripts
│   └── contracts/     # Smart contracts
├── contracts/         # Solidity smart contracts
├── scripts/           # Deployment and utility scripts
└── test/             # Contract tests
```

## 🔧 Smart Contracts

- **DAO.sol**: Main DAO governance contract with proposal and voting logic
- **GovernanceToken.sol**: ERC20 governance token with voting power
- **Treasury.sol**: Treasury management contract for fund allocation

## 🎯 Features

### Core Functionality
- **Governance**: Create and vote on proposals with time-limited voting periods
- **Treasury Management**: Manage DAO funds with multi-signature requirements
- **Admin Panel**: Administrative controls for DAO management
- **Real-time Updates**: WebSocket integration for live proposal updates
- **Wallet Integration**: Seamless MetaMask connectivity

### User Experience
- **Responsive Design**: Mobile-friendly interface with TailwindCSS
- **Protected Routes**: Secure navigation with wallet-based authentication
- **Error Handling**: Comprehensive error management and user feedback
- **Navigation**: Intuitive UI with back buttons and clear navigation paths

## 🧪 Testing

### Local Development
1. Connect MetaMask to local network:
   - **RPC URL**: http://localhost:8545
   - **Chain ID**: 31337
   - **Currency Symbol**: ETH

2. Import test accounts from Hardhat console output
3. Start using the DAO platform with test ETH

### Test Accounts
Hardhat provides 20 test accounts with 10,000 ETH each for development and testing.

## 📋 Development Commands

```bash
# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test

# Deploy to local network
npx hardhat run scripts/deploy.js --network localhost

# Deploy to testnet (Sepolia)
npx hardhat run scripts/deploy.js --network sepolia

# Check contract verification
npx hardhat verify --network sepolia <contract_address>
```

## 🔑 Environment Variables

### Backend (.env)
```env
PORT=3001
PRIVATE_KEY=your_private_key_here
INFURA_PROJECT_ID=your_infura_project_id
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/your_project_id
ETHERSCAN_API_KEY=your_etherscan_api_key
```

### Frontend (.env)
```env
VITE_API_URL=http://localhost:3001
VITE_CHAIN_ID=31337
VITE_CONTRACT_ADDRESS=deployed_contract_address
```

## 🔐 Admin Configuration

Admin access is configured through hardcoded addresses in:
- `frontend/src/components/Navbar.jsx`
- `frontend/src/components/AdminPanel.jsx`

Current admin addresses are set in the `adminAddresses` array within these components.

## 🛠️ Tech Stack

### Frontend
- **React 18**: Modern React with hooks and functional components
- **Vite**: Fast build tool and development server
- **TailwindCSS**: Utility-first CSS framework
- **Wagmi**: React hooks for Ethereum
- **Ethers.js**: Ethereum library for blockchain interaction

### Backend
- **Node.js**: Runtime environment
- **Express.js**: Web application framework
- **WebSocket**: Real-time communication
- **Prisma**: Database ORM (optional)

### Blockchain
- **Hardhat**: Ethereum development environment
- **Solidity**: Smart contract programming language
- **OpenZeppelin**: Secure smart contract library
- **MetaMask**: Browser wallet integration

## 🚀 Deployment

### Local Development
1. All services running on localhost
2. Local Hardhat blockchain network
3. Test accounts with unlimited ETH

### Testnet Deployment (Sepolia)
1. Configure environment variables
2. Fund deployer account with Sepolia ETH
3. Run deployment scripts
4. Verify contracts on Etherscan

### Production Considerations
- Use environment-specific configurations
- Implement proper secret management
- Set up monitoring and logging
- Configure proper CORS policies

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Troubleshooting

### Common Issues
1. **MetaMask Connection**: Ensure you're connected to the correct network
2. **Transaction Failures**: Check account balance and gas fees
3. **Contract Errors**: Verify contract deployment and ABI configuration
4. **CORS Issues**: Ensure backend CORS settings allow frontend origin

### Getting Help
- Check the console for detailed error messages
- Verify all environment variables are set correctly
- Ensure all services are running (blockchain, backend, frontend)
- Check MetaMask network configuration

## 📊 Project Status

- ✅ **Smart Contracts**: Deployed and tested
- ✅ **Frontend**: React app with full DAO interface
- ✅ **Backend**: API server with WebSocket support
- ✅ **Integration**: End-to-end functionality working
- ✅ **Documentation**: Comprehensive setup and usage guides
- ✅ **Testing**: Local development environment ready

---

**Built with ❤️ for decentralized governance**
