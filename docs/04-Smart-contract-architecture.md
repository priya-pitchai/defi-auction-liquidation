# Smart Contract Design

## Overview

The Auction-Based DeFi Lending Protocol is designed using a modular architecture, where each smart contract has a single responsibility. This improves maintainability, readability, security, and scalability.

The protocol consists of the following five core smart contracts:

1. `CollateralVault.sol`
2. `Treasury.sol`
3. `LoanManager.sol`
4. `LiquidationManager.sol`
5. `LiquidationAuction.sol`
6. `PriceOracle.sol`

---

# 1. CollateralVault.sol

## Responsibility

Securely stores all ETH collateral deposited by borrowers.

## Main Functions

- `depositCollateral()`
- `withdrawCollateral()`
- `getCollateral()`

## Stores

- Borrower collateral balances
- Deposit timestamps

## Interacts With

- `LoanManager.sol`
- `LiquidationManager.sol`

---

# 2. Treasury.sol

## Responsibility

Manages the protocol's shared liquidity pool funded by lenders.

## Main Functions

- `depositLiquidity()`
- `withdrawLiquidity()`
- `disburseLoan()`
- `receiveRepayment()`
- `receiveAuctionProceeds()`

## Stores

- Total liquidity
- Available liquidity
- Lender balances

## Interacts With

- `LoanManager.sol`
- `LiquidationAuction.sol`

---

# 3. LoanManager.sol

## Responsibility

Acts as the core controller of the protocol and manages the complete loan lifecycle.

## Main Functions

- `createLoan()`
- `approveLoan()`
- `repayLoan()`
- `calculateHealthFactor()`

## Stores

- Loan details
- Interest rate
- Loan status
- Borrower information

## Interacts With

- `CollateralVault.sol`
- `Treasury.sol`
- `Price Oracle`
- `LiquidationManager.sol`

---

# 4. LiquidationManager.sol

## Responsibility

Monitors the health of active loans and initiates liquidation when the collateral ratio falls below the liquidation threshold.

## Main Functions

- `checkLoanHealth()`
- `triggerLiquidation()`

## Stores

- Liquidation threshold
- Health factor

## Interacts With

- `LoanManager.sol`
- `Price Oracle`
- `LiquidationAuction.sol`

---

# 5. LiquidationAuction.sol

## Responsibility

Conducts auctions for liquidated collateral and settles the auction after completion.

## Main Functions

- `createAuction()`
- `placeBid()`
- `endAuction()`

## Stores

- Auction details
- Highest bid
- Highest bidder
- Auction status

## Interacts With

- `Treasury.sol`
- `LiquidationManager.sol`

---

# Contract Responsibilities Summary

| Smart Contract | Primary Responsibility |
|----------------|------------------------|
| **CollateralVault.sol** | Securely stores borrower collateral. |
| **Treasury.sol** | Manages lender liquidity and loan funds. |
| **LoanManager.sol** | Handles the complete loan lifecycle. |
| **LiquidationManager.sol** | Monitors loan health and triggers liquidation. |
| **LiquidationAuction.sol** | Conducts collateral auctions and settles winning bids. |

---

# Contract Interaction Overview

```text
                 Chainlink Price Feed
                         ▲
                         │
                  reads from
                         │
                  PriceOracle.sol
                         ▲
                         │
     +-------------------+------------------+
     |                                      |
LoanManager                     LiquidationManager
     |                                      |
     +-------------------+------------------+
                         │
                         ▼
                  CollateralVault
                         │
                         ▼
                     Treasury
                         │
                         ▼
               LiquidationAuction
```

# Design Principles

The smart contract architecture follows the following design principles:

- **Single Responsibility Principle (SRP)** – Each contract has one well-defined responsibility.
- **Modular Design** – Contracts are independent and communicate through clearly defined interfaces.
- **Separation of Concerns** – Loan management, collateral management, treasury operations, liquidation, and auctions are handled independently.
- **Scalability** – New collateral types, stablecoins, auction mechanisms, or governance features can be added with minimal impact on existing contracts.
- **Security** – Keeping responsibilities isolated reduces the attack surface and simplifies security audits.

---

# Future Enhancements

The current architecture represents the Minimum Viable Product (MVP). Future versions may include:

- Support for multiple collateral assets.
- Variable interest rates.
- Partial loan repayments.
- Collateral top-up.
- Additional borrowing based on increased collateral value.
- Multiple stablecoins.
- DAO governance.
- Reward mechanism for liquidity providers.
- Cross-chain collateral support.