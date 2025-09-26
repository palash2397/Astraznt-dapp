//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;


//  $$$$$$\   $$$$$$\ $$$$$$$$\ $$$$$$$\   $$$$$$\  $$$$$$$$\ $$\   $$\ $$$$$$$$\
// $$  __$$\ $$  __$$\\__$$  __|$$  __$$\ $$  __$$\ \____$$  |$$$\  $$ |\__$$  __|
// $$ /  $$ |$$ /  \__|  $$ |   $$ |  $$ |$$ /  $$ |    $$  / $$$$\ $$ |   $$ |
// $$$$$$$$ |\$$$$$$\    $$ |   $$$$$$$  |$$$$$$$$ |   $$  /  $$ $$\$$ |   $$ |
// $$  __$$ | \____$$\   $$ |   $$  __$$< $$  __$$ |  $$  /   $$ \$$$$ |   $$ |
// $$ |  $$ |$$\   $$ |  $$ |   $$ |  $$ |$$ |  $$ | $$  /    $$ |\$$$ |   $$ |
// $$ |  $$ |\$$$$$$  |  $$ |   $$ |  $$ |$$ |  $$ |$$$$$$$$\ $$ | \$$ |   $$ |
// \__|  \__| \______/   \__|   \__|  \__|\__|  \__|\________|\__|  \__|   \__|


import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./AZNTVirtual.sol";
import "./MTBVirtual.sol";

contract AZNTStaking is Ownable, ReentrancyGuard {

    ERC20 public immutable azntToken;
    AZNTVirtual public immutable azntVirtual;
    MTBVirtual public immutable mtbVirtual;

    uint256 public constant MIN_STAKE = 1e6;
    uint256 public constant MAX_STAKE = 10000000e6;
    uint256 public constant DAY_IN_SECONDS = 86400;
    bool public stakingEnabled = true;

    uint256 public constant UNSTAKE_FEE_PERCENT = 5;
    uint256 public constant REFERRAL_CLAIM_FEE_PERCENT = 5;
    uint256 public collectedFees;

    struct Stake {
        uint256 amount;
        uint256 lockPeriod;
        uint256 startTime;
        uint256 lastClaimTime;
        uint256 priceTier;
        bool isActive;
    }

    struct LevelReq {
        uint256 requiredStake;
        uint256 requiredDirectRefs;
        uint256 percentage;
    }


    mapping(address => Stake[]) public userStakes;
    mapping(address => address) public referrerOf;
    mapping(address => uint256) public totalReferralCount;
    mapping(address => uint256) public referralEarnings;
    mapping(uint256 => mapping(uint256 => uint256)) public apyTiers;

    LevelReq[10] public referralLevels;

    event Staked(address indexed user, uint256 amount, uint256 lockPeriod, uint256 priceTier, address referrer);
    event RewardsClaimed(address indexed user, uint256 amount);
    event ReferralEarned(address indexed referrer, uint256 amount);
    event Unstaked(address indexed user, uint256 rewards, uint256 fee);
    event ReferralRecorded(address indexed user, address indexed referrer);

    constructor(address _azntToken, address _azntVirtual, address _mtbVirtual) Ownable(msg.sender) {
        azntToken = ERC20(_azntToken);
        azntVirtual = AZNTVirtual(_azntVirtual);
        mtbVirtual = MTBVirtual(_mtbVirtual);

        // Initialize referral levels (ADDED for Week 3)
        referralLevels[0] = LevelReq(100e6, 1, 15);
        referralLevels[1] = LevelReq(500e6, 2, 10);
        referralLevels[2] = LevelReq(1000e6, 3, 5);
        referralLevels[3] = LevelReq(2000e6, 4, 5);
        referralLevels[4] = LevelReq(3000e6, 5, 5);
        referralLevels[5] = LevelReq(4000e6, 6, 5);
        referralLevels[6] = LevelReq(5000e6, 7, 5);
        referralLevels[7] = LevelReq(6000e6, 8, 5);
        referralLevels[8] = LevelReq(8000e6, 9, 5);
        referralLevels[9] = LevelReq(10000e6, 10, 2);

        // Initialize APY tiers
        apyTiers[360][0] = 1200;
        apyTiers[360][1] = 800;
        apyTiers[360][2] = 400;
        apyTiers[360][3] = 150;

        apyTiers[180][0] = 300;
        apyTiers[180][1] = 200;
        apyTiers[180][2] = 100;
        apyTiers[180][3] = 50;
    }

    function stake(uint256 amount, uint256 lockPeriod, address referrer) external nonReentrant {
        require(stakingEnabled, "Staking is disabled");
        require(lockPeriod == 180 || lockPeriod == 360, "Invalid lock period");
        require(amount >= MIN_STAKE && amount <= MAX_STAKE, "Invalid stake amount");

        require(azntToken.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        uint256 currentPrice = getAZNTPrice();
        uint256 priceTier = getPriceTier(currentPrice);

        // Referral recording (ADDED for Week 3)
        if (referrer != address(0) && referrer != msg.sender && referrerOf[msg.sender] == address(0)) {
            referrerOf[msg.sender] = referrer;
            totalReferralCount[referrer]++;
            emit ReferralRecorded(msg.sender, referrer);
        }

        userStakes[msg.sender].push(Stake({
            amount: amount,
            lockPeriod: lockPeriod,
            startTime: block.timestamp,
            lastClaimTime: block.timestamp,
            priceTier: priceTier,
            isActive: true
        }));

        emit Staked(msg.sender, amount, lockPeriod, priceTier, referrer);
    }

    function claimRewards(uint256 stakeIndex) external nonReentrant {
        require(stakeIndex < userStakes[msg.sender].length, "Invalid stake index");
        Stake storage userStake = userStakes[msg.sender][stakeIndex];
        require(userStake.isActive, "Stake is not active");

        uint256 reward = calculateRewards(msg.sender, stakeIndex);
        require(reward > 0, "No rewards to claim");

        userStake.lastClaimTime = block.timestamp;
        
    
        distributeReferralRewards(msg.sender, reward);
        
        require(azntToken.transfer(msg.sender, reward), "Reward transfer failed");

        emit RewardsClaimed(msg.sender, reward);
    }

    function unstake(uint256 stakeIndex) external nonReentrant {
        require(stakeIndex < userStakes[msg.sender].length, "Invalid stake index");
        Stake storage userStake = userStakes[msg.sender][stakeIndex];
        require(userStake.isActive, "Stake is not active");
        require(block.timestamp >= userStake.startTime + (userStake.lockPeriod * DAY_IN_SECONDS), "Lock period not ended");

        uint256 reward = calculateRewards(msg.sender, stakeIndex);
        uint256 principal = userStake.amount;

        // Apply unstaking fee (ADDED for Week 3)
        uint256 fee = (reward * UNSTAKE_FEE_PERCENT) / 100;
        uint256 netReward = reward - fee;
        collectedFees += fee;

        // Multi-token distribution (ADDED for Week 3)
        uint256 azntReward = (netReward * 50) / 100;
        uint256 azntVirtualReward = (netReward * 30) / 100;
        uint256 mtbVirtualReward = netReward - azntReward - azntVirtualReward;

        // Transfer tokens
        require(azntToken.transfer(msg.sender, principal + azntReward), "Transfer failed");
        azntVirtual.mint(msg.sender, azntVirtualReward);
        mtbVirtual.mint(msg.sender, mtbVirtualReward);

        userStake.isActive = false;
        emit Unstaked(msg.sender, netReward, fee);
    }

    function distributeReferralRewards(address user, uint256 reward) internal {
        address currentReferrer = referrerOf[user];
        uint256 level = 0;

        while (currentReferrer != address(0) && level < 10) {
            if (isQualifiedForLevel(currentReferrer, level)) {
                uint256 levelPercentage = referralLevels[level].percentage;
                uint256 referralReward = (reward * levelPercentage) / 100;

                referralEarnings[currentReferrer] += referralReward;
                emit ReferralEarned(currentReferrer, referralReward);
            }

            currentReferrer = referrerOf[currentReferrer];
            level++;
        }
    }

    function claimReferralRewards() external nonReentrant {
        uint256 earnings = referralEarnings[msg.sender];
        require(earnings > 0, "No referral earnings to claim");

        uint256 fee = (earnings * REFERRAL_CLAIM_FEE_PERCENT) / 100;
        uint256 netEarnings = earnings - fee;
        collectedFees += fee;

        uint256 azntAmount = netEarnings / 2;
        uint256 azntVirtualAmount = netEarnings - azntAmount;

        require(azntToken.transfer(msg.sender, azntAmount), "Transfer failed");
        azntVirtual.mint(msg.sender, azntVirtualAmount);

        referralEarnings[msg.sender] = 0;
        emit ReferralEarned(msg.sender, netEarnings);
    }

    function isQualifiedForLevel(address user, uint256 level) public view returns (bool) {
        if (level >= 10) return false;
        LevelReq memory requirement = referralLevels[level];
        uint256 totalStake = getTotalStake(user);
        if (totalStake < requirement.requiredStake) return false;
        if (totalReferralCount[user] < requirement.requiredDirectRefs) return false;
        return true;
    }

    function calculateRewards(address user, uint256 stakeIndex) public view returns (uint256) {
        Stake memory userStake = userStakes[user][stakeIndex];
        if (!userStake.isActive) return 0;

        uint256 timeElapsed = block.timestamp - userStake.lastClaimTime;
        uint256 daysElapsed = (timeElapsed * 1e18) / DAY_IN_SECONDS;

        if (daysElapsed == 0) return 0;

        uint256 apy = apyTiers[userStake.lockPeriod][userStake.priceTier];
        uint256 rewards = (userStake.amount * apy * daysElapsed) / (365 * 100 * 1e18);
        return rewards;
    }

    function getTotalStake(address user) public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < userStakes[user].length; i++) {
            if (userStakes[user][i].isActive) {
                total += userStakes[user][i].amount;
            }
        }
        return total;
    }

    function getAZNTPrice() public pure returns (uint256) {
        return 100;
    }

    function getPriceTier(uint256 price) public pure returns (uint256) {
        if (price <= 100) return 0;
        if (price <= 500) return 1;
        if (price <= 1000) return 2;
        return 3;
    }

    function setApyTier(uint256 lockPeriod, uint256 priceTier, uint256 apyValue) external onlyOwner {
        apyTiers[lockPeriod][priceTier] = apyValue;
    }

    function setStakingState(bool enabled) external onlyOwner {
        stakingEnabled = enabled;
    }

    function withdrawFees(uint256 amount) external onlyOwner {
        require(amount <= collectedFees, "Amount exceeds collected fees");
        collectedFees -= amount;
        require(azntToken.transfer(owner(), amount), "Fee transfer failed");
    }

    function updateReferralLevel(uint256 level, uint256 requiredStake, uint256 requiredDirectRefs, uint256 percentage) external onlyOwner {
        require(level < 10, "Invalid level");
        referralLevels[level] = LevelReq(requiredStake, requiredDirectRefs, percentage);
    }
}