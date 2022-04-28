// FUNCTIONS TO BE IMPLEMENTED

// stake: Lock tokens into our Smart Contract ✅
// withdraw: (unstake) unlock tokens and pull out of the Smart Contract ✅
// claimReward: users get their reward tokens (earned by staking)

//      What's a good reward mechanism?
//      What's good reward maths?

// PSDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Custom Errors
error Staking__TransferFailed();
error Withdraw__TransferFailed();

contract Staking {

    IERC20 public s_stakingToken; // 's_' indicating its going to be 'storage' (expensirve to read and write)
    // || IERC20: OpenZeppeling interface for ERC20 tokens

    // user address => staking balance
    mapping(address => uint256) public s_balances;

    // track total supply of tokens in the Smart Contract
    uint256 public s_totalSupply;

    // modifier for updateRewards
    modifier updateRewards(address account) {
        // how much reward per token?
        // last timestamp
        // 12 -1, user earns x tokens
        _;
    }

    constructor(address stakingToken) {
        s_stakingToken = IERC20(stakingToken);
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
    function stake(uint256 amount) external {
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
    function withdraw(uint256 amount) external {
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
    *  staked: 50 staked tokens, 20 staked tokens, 30 staked tokens
    *  rewards: 50 reward tokens, 20 reward tokens, 30 reward tokens
    *
    *  staked: 100, 50, 20, 30 (total = 200)
    *  rewards: 50, 25, 10, 15
    *
    * - In 5 seconds, 1 person had 100 token staked = reward 500 tokens
    * - In second 6 (1 more from second 5), 2 persons have 100 tokens staked each:
    *     Person 1: 550 reward
    *     Person 2: 50 reward
    *   between seconds 1 and 5, person 1 got 500 tokens
    *   at second 6 on, person 1 gets 50 tokens now (100 reward tokens in total divided between num of stakers (2))
    */
    function claimReward() external {

    }
}