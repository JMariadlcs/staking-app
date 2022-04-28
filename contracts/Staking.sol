// FUNCTIONS TO BE IMPLEMENTED

// stake: Lock tokens into our Smart Contract ✅
// withdraw: (unstake) unlock tokens and pull out of the Smart Contract ✅
// claimReward: users get their reward tokens (earned by staking)

//      What's a good reward mechanism?
//      What's good reward maths?

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Custom Errors
error Staking__TransferFailed();
error Withdraw__TransferFailed();
error Claim__TransferFailed();
error Staking__NeedsMoreThanZero();

contract Staking {

    IERC20 public s_stakingToken; // 's_' indicating its going to be 'storage' (expensirve to read and write)
    // || IERC20: OpenZeppeling interface for ERC20 tokens
    IERC20 public s_rewardToken; // same but token used for rewards

    // user address => staking balance | how much each address has been paid | how much rewards each address has
    mapping(address => uint256) public s_balances;
    mapping(address => uint256) public s_userRewardPerTokenPaid;
    mapping(address => uint256) public s_rewards;

    // track total supply of tokens in the Smart Contract || calculation of reward/tokenstored || staking snapshots
    uint256 public constant REWARD_RATE = 100;
    uint256 public s_totalSupply;
    uint256 public s_rewardPerTokenStored;
    uint256 public s_lastUpdatedTime; 

    // modifier for updateRewards
    modifier updateReward(address account) {
        // how much reward per token?
        // last timestamp
        // 12 -1, user earns x tokens
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdatedTime = block.timestamp; // update snapshot
        s_rewards[account] = earned(account);
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
        _;
    }

    // modifier to check if balances are > 0
    modifier moreThanZero(uint256 amount) {
        if(amount == 0){
            revert Staking__NeedsMoreThanZero();
        }
        _;
    }

    constructor(address stakingToken, address rewardToken) {
        s_stakingToken = IERC20(stakingToken);
        s_rewardToken = IERC20(rewardToken);
    }

    /**
    * @dev 
    * - Calculate total earned tokens of a user
    * - Need to take into account how much they have been paid already
    */
    function earned(address account) public view returns(uint256) {
        uint256 currentBalance = s_balances[account];
        uint256 amountPaid = s_userRewardPerTokenPaid[account]; // how much user has already been paid
        uint256 currentRewardPerToken = rewardPerToken();
        uint256 pastRewards = s_rewards[account];

        uint256 total_earned = ((currentBalance * (currentRewardPerToken - amountPaid)) / 1e18) + pastRewards;
        return total_earned;
    }

    /**
    * @dev 
    * - Functionality: calculate the math for rewardPerToken staked
    * - Based on how long it's been during this most recent snapshot
    * - Formula comes from math mechanism defined in THIS specific DEFI APP
    */
    function rewardPerToken() public view returns(uint256) {
        if (s_totalSupply == 0) { // case: nothing staked
            return s_rewardPerTokenStored;
        }

        return s_rewardPerTokenStored + ((block.timestamp - s_lastUpdatedTime) * REWARD_RATE * 1e18 / s_totalSupply); //*1e18 because being in wei
    }
    
   /**
    * @notice 
    * - do we allow any tokens? -> no | if we allo any token -> use Chainlink stuff to convert prices between tokens
    * - or we allow just specific token? -> add token address
    * - user will need to call approve() for the ERC20 token before calling staking otherwise .transferFrom() will fail
    */
    /**
    * @dev 
    * - keep track how much user has staked
    * - keep track of how much tokens we have total
    * - transfer the tokens to this contract
    */
    /**
    * @param
    * - external: cheaper than public (we are not caling staking inside this contract)
    *//** */
    function stake(uint256 amount) external updateReward(msg.sender) moreThanZero(amount) {
        // IMPORTANT: update balances before .transferFrom() to avoid -> ¡¡REENTRANCY ATTACKS!!
        s_balances[msg.sender] =  s_balances[msg.sender] + amount;
        s_totalSupply = s_totalSupply + amount;
        // emit event
        bool success = s_stakingToken.transferFrom(msg.sender, address(this), amount); //.transferFrom from IERC20 OpenZeppeling
        
        // require(success, "Failed transaction"); // substituted by customed erros (because require "" is very expensive)
        if(!success) {
            revert Staking__TransferFailed(); // revert: all the things done before (balanced updated) wont be executed
        }
    }

   /**
    * @notice 
    * - user wont need to approve before withdraw() because now .transfer() can be executed by the contract 
    * because it actually owns the tokens in that moment (before withdrawing)
    */
    function withdraw(uint256 amount) external updateReward(msg.sender) moreThanZero(amount) {
         s_balances[msg.sender] =  s_balances[msg.sender] - amount;
         s_totalSupply = s_totalSupply - amount;
         //emit event
         bool success = s_stakingToken.transfer(msg.sender, amount);
         
         if(!success) {
            revert Withdraw__TransferFailed(); // revert: all the things done before (balanced updated) wont be executed
        }
    }

    /**
    * @notice 
    * - How much reward do they get? -> each DEFI app has own mechanism
    * - Why not 1 to 1 staked reward? -> bankrupt your protocol
    */
    /**
    * @dev 
    * - Contract is going to emit X tokens per second
    * - Disperse them to all the token stakers
    *
    * - 100 reward tokens / second (in total) -> THE MORE PEOPLE STAKE: THE LESS REWARDS GENERATED FOR EACH
    *
    * - In 5 seconds, 1 person had 100 token staked = reward 500 tokens
    * - In second 6 (1 more from second 5), 2 persons have 100 tokens staked each:
    *     Person 1: 550 reward
    *     Person 2: 50 reward
    *   between seconds 1 and 5, person 1 got 500 tokens
    *   at second 6 on, person 1 gets 50 tokens now (100 reward tokens in total divided between num of stakers (2))
    *
    *                                              ---EXAMPLE---
    * Time = 0
    * Person A: 80 staked
    * Person B: 20 staked
    *
    * Time = 1
    * Person A: Staked: 80, Earned: 80, Withdrawn: 0
    * Person B: Staked: 20, Earned: 20, Withdrawn: 0
    *
    * Time = 2
    * Person A: Staked: 80, Earned: 160, Withdrawn: 0
    * Person B: Staked: 20, Earned: 40, Withdrawn: 0
    *
    * NEW PERSON ENTERS! -> stake: 100 | totalStaked: 200
    *
    * Time = 3
    * Person A: Staked: 80, Earned: 160 + (stakeA/totalStaked)*100 -> (80/200)*100: 40 , Withdrawn: 0
    * Person B: Staked: 20, Earned: 40 + (stakeB/totalStaked)*100 -> (20/200)*100: 10 , Withdrawn: 0
    * Person C: Staked: 100, Earned: (stakedC/totalStaked) -> (100/200)*100: 50, Withdrawn: 0
    */
    function claimReward() external updateReward(msg.sender) { // first it does: updateReward
        uint256 reward = s_rewards[msg.sender]; // we get the rewards of the address to transfer them
        bool success = s_rewardToken.transfer(msg.sender, reward);

        if(!success) {
            revert Claim__TransferFailed();
        }
    }
}