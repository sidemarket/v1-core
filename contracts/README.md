# Contracts

Each folder in our codebase contains a single contract deployed to the mainnet (except _interfaces_ and _libraries_). This contract is known as the "entry point" and serves as the starting point for executing the functions defined within the contract.


### Transaction

- **Description**: The decentralized escrow system.
- **Entry point**: `TransactionManager.sol`

### Token

- **Description**: ERC-20 token implementation.
- **Entry point**: `SidemToken.sol`

### Stake

- **Description**: Contract to stake SIDEM and withdraw rewards.
- **Entry point**: `StakeManager.sol`

### Middleman

- **Description**: Contracts to ensure transaction safety.
- **Entry point**: `MiddlemanManager.sol`

## Libraries

### StablecoinAgent.sol

Simple library to access stablecoin contracts.

