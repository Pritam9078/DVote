# DVote Render Deployment Guide

## 🚀 Complete Render Configuration

### **Backend Service Configuration:**

| Field | Value |
|-------|-------|
| **Service Type** | Web Service |
| **Name** | `dvote-backend` |
| **Repository** | `https://github.com/Pritam9078/dvt` |
| **Branch** | `main` |
| **Root Directory** | `backend` |
| **Runtime** | `Node` |
| **Build Command** | `npm install` |
| **Start Command** | `npm start` |
| **Health Check Path** | `/health` |
| **Auto-Deploy** | `On` |
| **Pre-Deploy Command** | *(Leave empty)* |

### **Frontend Service Configuration:**

| Field | Value |
|-------|-------|
| **Service Type** | Static Site |
| **Name** | `dvote-frontend` |
| **Repository** | `https://github.com/Pritam9078/dvt` |
| **Branch** | `main` |
| **Root Directory** | `frontend` |
| **Build Command** | `npm install && npm run build` |
| **Publish Directory** | `dist` |
| **Auto-Deploy** | `On` |
| **Pre-Deploy Command** | *(Leave empty)* |

### **Build Filters:**

For both services, use these build filters to optimize deployments:

**Include Paths:**
```
backend/**
frontend/**
package.json
README.md
.env.production.*
render.yaml
```

**Ignore Paths:**
```
scripts/**
test/**
*.md
.git/**
node_modules/**
.env
.env.local
```

---

## 📋 **Environment Variables Setup**

### **Backend Environment Variables:**
Copy from `.env.production.backend`:
```bash
NODE_ENV=production
PORT=10000
ALCHEMY_API_KEY=9AtpJokx3QwzkXIVlNlR1
ETHERSCAN_API_KEY=R9VBBG99K3K5YDG9TQ6XXT2MMHJMZHBY82
SEPOLIA_URL=https://eth-sepolia.g.alchemy.com/v2/9AtpJokx3QwzkXIVlNlR1
PINATA_API_KEY=e12c30b1ac196f7c57a4
PINATA_SECRET_API_KEY=cd83a69bf3e87d8945a774cca94cdca7efc31e8313a0471fd9f7e972fcb0eda2
PINATA_JWT=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySW5mb3JtYXRpb24iOnsiaWQiOiJlYTVkZDJkZS03YTcwLTQxNzktYTlhOC0xNjY1NmQ4NTEzYTkiLCJlbWFpbCI6ImRwcml0YW0yNzA4QGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJwaW5fcG9saWN5Ijp7InJlZ2lvbnMiOlt7ImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxLCJpZCI6IkZSQTEifSx7ImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxLCJpZCI6Ik5ZQzEifV0sInZlcnNpb24iOjF9LCJtZmFfZW5hYmxlZCI6ZmFsc2UsInN0YXR1cyI6IkFDVElWRSJ9LCJhdXRoZW50aWNhdGlvblR5cGUiOiJzY29wZWRLZXkiLCJzY29wZWRLZXlLZXkiOiJlMTJjMzBiMWFjMTk2ZjdjNTdhNCIsInNjb3BlZEtleVNlY3JldCI6ImNkODNhNjliZjNlODdkODk0NWE3NzRjY2E5NGNkY2E3ZWZjMzFlODMxM2EwNDcxZmQ5ZjdlOTcyZmNiMGVkYTIiLCJleHAiOjE3OTE3Mzc3NTB9.jQyUe-KLI1qEsznmVW1Dt1nhfk7wTb21G00-Iv7GKpw
OWNER_ADDRESS=0xa62463A56EE9D742F810920F56cEbc4B696eBd0a
```

### **Frontend Environment Variables:**
Copy from `.env.production.frontend`:
```bash
VITE_PINATA_API_KEY=e12c30b1ac196f7c57a4
VITE_PINATA_SECRET_API_KEY=cd83a69bf3e87d8945a774cca94cdca7efc31e8313a0471fd9f7e972fcb0eda2
VITE_PINATA_JWT=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySW5mb3JtYXRpb24iOnsiaWQiOiJlYTVkZDJkZS03YTcwLTQxNzktYTlhOC0xNjY1NmQ4NTEzYTkiLCJlbWFpbCI6ImRwcml0YW0yNzA4QGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJwaW5fcG9saWN5Ijp7InJlZ2lvbnMiOlt7ImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxLCJpZCI6IkZSQTEifSx7ImRlc2lyZWRSZXBsaWNhdGlvbkNvdW50IjoxLCJpZCI6Ik5ZQzEifV0sInZlcnNpb24iOjF9LCJtZmFfZW5hYmxlZCI6ZmFsc2UsInN0YXR1cyI6IkFDVElWRSJ9LCJhdXRoZW50aWNhdGlvblR5cGUiOiJzY29wZWRLZXkiLCJzY29wZWRLZXlLZXkiOiJlMTJjMzBiMWFjMTk2ZjdjNTdhNCIsInNjb3BlZEtleVNlY3JldCI6ImNkODNhNjliZjNlODdkODk0NWE3NzRjY2E5NGNkY2E3ZWZjMzFlODMxM2EwNDcxZmQ5ZjdlOTcyZmNiMGVkYTIiLCJleHAiOjE3OTE3Mzc3NTB9.jQyUe-KLI1qEsznmVW1Dt1nhfk7wTb21G00-Iv7GKpw
VITE_ALCHEMY_API_KEY=9AtpJokx3QwzkXIVlNlR1
VITE_ETHERSCAN_API_KEY=R9VBBG99K3K5YDG9TQ6XXT2MMHJMZHBY82
VITE_WALLETCONNECT_PROJECT_ID=a7b2f3c4d5e6f7a8b9c0d1e2f3a4b5c6
VITE_BACKEND_URL=https://YOUR-BACKEND-NAME.onrender.com
VITE_WS_URL=wss://YOUR-BACKEND-NAME.onrender.com
```

> **Important:** Update `VITE_BACKEND_URL` and `VITE_WS_URL` with your actual backend service URL after deployment.

---

## 🔧 **Step-by-Step Deployment**

### **Step 1: Deploy Backend**
1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click "New" → "Web Service"
3. Connect your GitHub repository: `https://github.com/Pritam9078/dvt`
4. Use the backend configuration above
5. Add all backend environment variables
6. Click "Create Web Service"

### **Step 2: Deploy Frontend**
1. Click "New" → "Static Site"
2. Connect the same GitHub repository
3. Use the frontend configuration above
4. Add all frontend environment variables
5. **Update `VITE_BACKEND_URL` with your backend URL from Step 1**
6. Click "Create Static Site"

### **Step 3: Optional Database**
If you need persistent data:
1. Add PostgreSQL database add-on to backend service
2. Copy the `DATABASE_URL` to backend environment variables

---

## 🌐 **Live URLs**
After deployment, your DVote platform will be available at:
- **Frontend**: `https://dvote-frontend.onrender.com`
- **Backend API**: `https://dvote-backend.onrender.com`
- **Health Check**: `https://dvote-backend.onrender.com/health`

---

**🎉 Your DVote DAO platform is now ready for production!**
