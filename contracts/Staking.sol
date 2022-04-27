// FUNCTIONS TO BE IMPLEMENTED

// stake: Lock tokens into our Smart Contract
// withdraw: (unstake) unlock tokens and pull out of the Smart Contract
// claimReward: users get their reward tokens (earned by staking)

//      What's a good reward mechanism?
//      What's good reward maths?

// PSDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/tokens/ERC20/IERC20.sol";

// Custom Errors
error Staking__TransferFailed();

contract Staking {

    IERC20 public s_stakingToken; // 's_' indicating its going to be 'storage' (expensirve to read and write)
    // || IERC20: OpenZeppeling interface for ERC20 tokens

    // user address => staking balance
    mapping(address => uint256) public s_balances;

    // track total supply of tokens in the Smart Contract
    uint256 public s_totalSupply;

    constructor(address stakingToken) {
        s_stakingToken = stakingToken;
    }
    
    /**
    @notice 
    - do we allow any tokens? -> no | if we allo any token -> use Chainlink stuff to convert prices between tokens
    - or we allow just specific token? -> add token address
    - user will need to call approve() for the ERC20 token before calling staking otherwise .transferFrom() will fail
    @dev 
    - keep track how much user has staked
    - keep track of how much tokens we have total
    - transfer the tokens to this contract
    */
    function stake(uint256 amount) external {
        s_balances[msg.sender] =  s_balances[msg.sender] + amount;
        s_totalSupply = s_totalSupply + amount;
        // emit event
        bool success = s_stakingToken.transferFrom(msg.sender, address(this), amount); //.transferFrom from IERC20 OpenZeppeling
        // require(success, "Failed transaction"); // substituted by customed erros (because require "" is very expensive)
        if(!success) {
            revert Staking__TransferFailed();
        }
    }

    /**
    @notice 
    - user wont need to approve before withdraw() because now .transfer() can be executed by the contract 
    because it actually owns the tokens in that moment (before withdrawing)
    */
    function withdraw(uint256 amount) external {
         s_balances[msg.sender] =  s_balances[msg.sender] - amount;
         s_totalSupply = s_totalSupply - amount;

         bool succeess = s_stakingToken.transfer(msg.sender, amount);
    }
}