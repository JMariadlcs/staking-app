# STAKING-APP

This is a Staking App from a Chainlink Hackaton Spring 2022 workshop which is implemented by using Solidity and Hardhat.

## Objetives
Implement a Staking App with the following functionalities: 
1. stake: Lock tokens into our Smart Contract ✅
2. withdraw: (unstake) unlock tokens and pull out of the Smart Contract ✅
3. claimReward: users get their reward tokens (earned by staking) ✅

## Requirements for creating similar projects from scratch
- Start hardhat project:
```bash
npm init -y
npm install --save-dev hardhat
npx hardhat
```

- Install dependencies:
```bash
yarn add --dev @nomiclabs/hardhat-ethers@npm:hardhat-deploy-ethers ethers @nomiclabs/hardhat-etherscan @nomiclabs/hardhat-waffle chai ethereum-waffle hardhat hardhat-contract-sizer hardhat-deploy hardhat-gas-reporter prettier prettier-plugin-solidity solhint solidity-coverage dotenv
```

- Add .gitignore file containing:
```bash
node_modules
.env
coverage
coverage.json
typechain

#Hardhat files
cache
artifacts
```

## Resources
- [DeFi Staking App: Code Along](https://www.youtube.com/watch?v=-48_hdo9_gg&t=4447s): Chainlink Hackathon Spring 2022 workshop video
- [OpenZeppeling github](https://github.com/OpenZeppelin/openzeppelin-contracts): OpenZeppeling github
- [Solidity by example](https://solidity-by-example.org): Solidity examples
- [defi-minimal repo](https://github.com/smartcontractkit/defi-minimal): a repo with a lot of useful DEFI examples
- [hardhat-starter-kit](https://github.com/smartcontractkit/hardhat-starter-kit)