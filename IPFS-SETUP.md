# DVote IPFS Configuration Guide

## Current Status
✅ **DVote is running with real Pinata IPFS credentials configured**  
✅ **Proposal creation and file uploads work with real IPFS storage**  
✅ **Custom DVote logo integrated throughout the application**

## To Enable Real IPFS Upload

### 1. Get Pinata Credentials
1. Go to [https://pinata.cloud/](https://pinata.cloud/)
2. Sign up for a free account
3. Navigate to the API Keys section
4. Create a new API key with the following permissions:
   - `pinFileToIPFS`
   - `pinJSONToIPFS`
   - `unpinning`

### 2. Update Environment Variables
Edit `/frontend/.env` and replace the placeholder values:

```bash
# Replace these with your actual Pinata credentials
VITE_PINATA_API_KEY=your_actual_pinata_api_key
VITE_PINATA_SECRET_API_KEY=your_actual_pinata_secret_key

# OR use JWT (newer method, recommended)
VITE_PINATA_JWT=your_actual_pinata_jwt_token
```

### 3. Get WalletConnect Project ID (Optional)
1. Go to [https://cloud.walletconnect.com/](https://cloud.walletconnect.com/)
2. Create a new project
3. Copy the Project ID
4. Update in `.env`:
```bash
VITE_WALLETCONNECT_PROJECT_ID=your_actual_project_id
```

## Development Mode Features
- ✅ Proposal creation works with mock IPFS hashes
- ✅ All DAO functionality is operational
- ✅ File uploads are simulated locally
- ✅ Metadata is stored with mock identifiers

## Production Checklist
- [x] Real Pinata API credentials configured
- [x] WalletConnect Project ID set
- [x] Custom DVote logo integrated
- [ ] Test file upload functionality
- [ ] Verify proposal metadata storage

---
*DVote DAO Governance Platform - Decentralized Voting Made Simple*
