# Astraznt Staking DApp

A next-generation staking decentralized application (DApp) on the Tron blockchain, designed for the AZNT token ecosystem. This platform offers high-yield staking with dynamic APY, a multi-level referral system, and seamless SunSwap integration.

## Features

- **Dynamic Tiered APY**: Earn up to 1200% APY based on AZNT token price at staking time
- **Dual Lock Periods**: Choose between 180-day and 360-day staking periods
- **Multi-Level Referral System**: 10-level deep affiliate program with matching bonuses
- **Multi-Token Rewards**: Earn rewards in AZNT, AZNT(V), and MTB(V) tokens
- **SunSwap Integration**: Enforced fair token acquisition through decentralized swaps
- **Daily Claim Mechanism**: Active participation required with forfeiture of unclaimed rewards
- **Secure Smart Contracts**: Built with security best practices and comprehensive testing


## Smart Contract Architecture

### Core Contracts

- **AZNTStaking.sol**: Main staking contract managing user stakes, rewards, and referral logic
- **AZNTRewardV.sol**: TRC-20 virtual reward token (burnable within AZvertex ecosystem)
- **MTBRewardV.sol**: TRC-20 virtual reward token for AZvertex ecosystem

### Key Features

- **Staking Limits**: 1 TRX to 10,000 TRX worth of AZNT per user
- **Lock Periods**: 180 days (50-300% APY) and 360 days (150-1200% APY)
- **Reward Distribution**: 50% AZNT, 30% AZNT(V), 20% MTB(V)
- **5% Unstaking Fee**: Applied on total rewards at unstaking
- **10-Level Referral**: Matching bonuses up to 55% of downline earnings

## Getting Started

### Prerequisites

- Node.js 
- npm or yarn
- TronLink wallet
- Tron testnet TRX 

### Installation

1. Clone the repository:
```bash
git clone https://github.com/palash2397/Astraznt-dapp.git
cd Astraznt-dapp
```


### 3. Setup Environment Variables

Create a `.env` file in the root directory.  
All required credentials and variable names are listed in the `.env.example` file.

```bash
cp .env.example .env
```

> ⚠️ Never commit your `.env` file — it’s excluded via `.gitignore`.

---

# 🚀 Usage Guide

### ✅ Compile contracts

```bash
npx hardhat compile

```

### 🧪 Run Tests

```bash
npx hardhat test
```

### 🌐 Deploy to Tron testnet:

```bash
node scripts/aznt-deploy.js 
```

