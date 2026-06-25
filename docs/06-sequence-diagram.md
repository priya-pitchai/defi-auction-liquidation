# Sequence Diagrams

This document describes the interaction between protocol actors and smart contracts.

---

# 1. Loan Request

```text
Borrower
    |
    | Request Loan
    v
LoanManager
    |
    | Verify Collateral
    v
CollateralManager
    |
    | Request ETH Price
    v
PriceOracle
    |
    | Return Price
    ^
LoanManager
    |
    | Calculate Maximum Loan
    |
    | Validate Treasury Liquidity
    |
    v
Treasury
    |
    | Transfer Stablecoin
    v
Borrower
```

---

# 2. Loan Repayment

```text
Borrower
    |
    | Repay Loan
    v
LoanManager
    |
    | Validate Amount
    |
    v
Treasury
    |
    | Receive Stablecoin
    |
    ^
LoanManager
    |
    | Release Collateral
    v
CollateralManager
    |
    v
Borrower
```

---

# 3. Liquidation

```text
Keeper
    |
    | Check Loan Health
    v
LoanManager
    |
    | Request ETH Price
    v
PriceOracle
    |
    | Return Price
    ^
LoanManager
    |
    | Below Threshold?
    |
    v
LiquidationAuction
```

---

# 4. Auction Settlement

```text
Bidder
    |
    | Submit Bid
    v
LiquidationAuction
    |
    | Highest Bid Updated
    |
Auction Ends
    |
    v
LiquidationAuction
    |
    | Transfer Collateral
    v
Winning Bidder

LiquidationAuction
    |
    | Transfer Debt Amount
    v
Treasury

LiquidationAuction
    |
    | Transfer Surplus
    v
Borrower
```