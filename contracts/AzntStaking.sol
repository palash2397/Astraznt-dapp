// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

//  $$$$$$\   $$$$$$\ $$$$$$$$\ $$$$$$$\   $$$$$$\  $$$$$$$$\ $$\   $$\ $$$$$$$$\
// $$  __$$\ $$  __$$\\__$$  __|$$  __$$\ $$  __$$\ \____$$  |$$$\  $$ |\__$$  __|
// $$ /  $$ |$$ /  \__|  $$ |   $$ |  $$ |$$ /  $$ |    $$  / $$$$\ $$ |   $$ |
// $$$$$$$$ |\$$$$$$\    $$ |   $$$$$$$  |$$$$$$$$ |   $$  /  $$ $$\$$ |   $$ |
// $$  __$$ | \____$$\   $$ |   $$  __$$< $$  __$$ |  $$  /   $$ \$$$$ |   $$ |
// $$ |  $$ |$$\   $$ |  $$ |   $$ |  $$ |$$ |  $$ | $$  /    $$ |\$$$ |   $$ |
// $$ |  $$ |\$$$$$$  |  $$ |   $$ |  $$ |$$ |  $$ |$$$$$$$$\ $$ | \$$ |   $$ |
// \__|  \__| \______/   \__|   \__|  \__|\__|  \__|\________|\__|  \__|   \__|

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./AZNTVirtual.sol";
import "./MTBVirtual.sol";

// Main Staking Contract
contract AZNTStaking is Ownable, ReentrancyGuard {

    // Token contracts
    ERC20 public immutable azntToken; //  standard ERC20 token
    AZNTVirtual public immutable azntVirtual; //  custom contract
    MTBVirtual public immutable mtbVirtual; //  custom contract


    // Staking parameters
    uint256 public constant MIN_STAKE = 1e6; // 1 TRX worth of AZNT
    uint256 public constant MAX_STAKE = 10000000e6; // 10,000 TRX worth of AZNT
    uint256 public constant DAY_IN_SECONDS = 86400;
    bool public stakingEnabled = true;

    // Fee structure
    uint256 public constant UNSTAKE_FEE_PERCENT = 5;
    uint256 public constant REFERRAL_CLAIM_FEE_PERCENT = 5;

    // Stake structure
    struct Stake {
        uint256 amount;
        uint256 lockPeriod;
        uint256 startTime;
        uint256 lastClaimTime;
        uint256 azntPriceAtStake;
        bool isActive;
    }

    // Referral level requirements
    struct LevelReq {
        uint256 requiredStake;
        uint256 requiredDirectRefs;
        uint256 percentage;
    }

    // User mapping
    mapping(address => Stake[]) public userStakes;
    mapping(address => address) public referrerOf;
    mapping(address => uint256) public referralEarnings;
    mapping(address => uint256) public totalReferralCount;

    // APY configuration
    mapping(uint256 => mapping(uint256 => uint256)) public apyTiers; // lockPeriod -> priceTier -> apyValue

    // Referral levels configuration
    LevelReq[10] public referralLevels;

    // Events
    event Staked(address indexed user, uint256 amount, uint256 lockPeriod);
    event RewardsClaimed(address indexed user, uint256 amount);
    event ReferralEarned(address indexed referrer, uint256 amount);
    event Unstaked(address indexed user, uint256 principal, uint256 rewards);
    event ReferralRecorded(address indexed user, address indexed referrer);

    constructor(address _azntToken, address _azntVirtual, address _mtbVirtual) Ownable(msg.sender) {
        azntToken = ERC20(_azntToken);
        azntVirtual = AZNTVirtual(_azntVirtual);
        mtbVirtual = MTBVirtual(_mtbVirtual);

        // Initialize default referral levels (example values)
        referralLevels[0] = LevelReq(100e6, 1, 15);    // Level 1: 100 TRX staked, 1 direct ref, 15%
        referralLevels[1] = LevelReq(500e6, 2, 10);    // Level 2: 500 TRX staked, 2 direct refs, 10%
        referralLevels[2] = LevelReq(1000e6, 3, 5);    // Level 3: 1000 TRX staked, 3 direct refs, 5%
        referralLevels[3] = LevelReq(2000e6, 4, 5);    // Level 4: 2000 TRX staked, 4 direct refs, 5%
        referralLevels[4] = LevelReq(3000e6, 5, 5);    // Level 5: 3000 TRX staked, 5 direct refs, 5%
        referralLevels[5] = LevelReq(4000e6, 6, 5);    // Level 6: 4000 TRX staked, 6 direct refs, 5%
        referralLevels[6] = LevelReq(5000e6, 7, 5);    // Level 7: 5000 TRX staked, 7 direct refs, 5%
        referralLevels[7] = LevelReq(6000e6, 8, 5);    // Level 8: 6000 TRX staked, 8 direct refs, 5%
        referralLevels[8] = LevelReq(8000e6, 9, 5);    // Level 9: 8000 TRX staked, 9 direct refs, 5%
        referralLevels[9] = LevelReq(10000e6, 10, 2);  // Level 10: 10000 TRX staked, 10 direct refs, 2%

        // Initialize default APY tiers (example values)
        // 360-day lock period
        apyTiers[360][0] = 1200;   // Price tier 0: 1200% APY
        apyTiers[360][1] = 800;    // Price tier 1: 800% APY
        apyTiers[360][2] = 400;    // Price tier 2: 400% APY
        apyTiers[360][3] = 150;    // Price tier 3: 150% APY
 
        // 180-day lock period
        apyTiers[180][0] = 300;    // Price tier 0: 300% APY
        apyTiers[180][1] = 200;    // Price tier 1: 200% APY
        apyTiers[180][2] = 100;    // Price tier 2: 100% APY
        apyTiers[180][3] = 50;     // Price tier 3: 50% APY
    }

    // Main staking function
   
}