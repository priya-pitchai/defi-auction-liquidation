# Functional Flow

## Overview

This document describes the end-to-end business workflow of the Auction-Based DeFi Lending Protocol.

---

# 1. Treasury Funding

## Actors

- Lenders

## Description

Multiple lenders deposit stablecoins into the Treasury contract, creating a shared liquidity pool that is used to fund borrower loans.

## Flow

1. Lender connects their wallet.
2. Lender deposits stablecoins into the Treasury.
3. Treasury records the deposited amount.
4. Treasury updates the available liquidity.
5. Deposited funds become available for issuing loans.

## Validation

- Deposit amount must be greater than zero.
- Only supported stablecoins can be deposited.

## Output

- Treasury liquidity increases.
- Stablecoins become available for lending.

---

# 2. Borrower Deposits Collateral

## Actors

- Borrower

## Description

Borrowers must deposit ETH as collateral before requesting a loan.

## Flow

1. Borrower connects their wallet.
2. Borrower deposits ETH as collateral.
3. CollateralManager records:
   - Borrower address
   - Collateral amount
   - Deposit timestamp
4. ETH remains locked until the loan is repaid or liquidated.

## Validation

- Collateral amount must be greater than zero.

## Output

- Collateral is successfully locked.

---

# 3. Loan Request

## Actors

- Borrower

## Description

Borrower requests a stablecoin loan using the deposited ETH as collateral.

## Flow

1. Borrower submits the requested loan amount.
2. LoanManager retrieves:
   - Borrower's collateral amount
   - Current ETH/USD price from Chainlink Price Oracle
3. LoanManager calculates:
   - Collateral value
   - Maximum borrowable amount
4. Loan request is validated.

## Validation

- Borrower can have only one active loan.
- Requested amount must not exceed the maximum borrowable amount.
- Treasury must have sufficient liquidity.

## Output

- Loan enters the **Approved** state.

---

# 4. Loan Disbursement

## Actors

- LoanManager
- Treasury

## Description

Approved loans are funded from the Treasury.

## Flow

1. LoanManager instructs the Treasury to release funds.
2. Treasury transfers stablecoins to the borrower.
3. Loan status changes to **Active**.

## Output

- Borrower receives stablecoins.
- Treasury liquidity decreases.

---

# 5. Interest Accrual

## Description

Interest accumulates while the loan remains active.

## MVP Implementation

- Fixed annual interest rate.
- Interest is calculated only during repayment.
- Continuous interest accrual is not implemented.

---

# 6. Loan Repayment

## Actors

- Borrower

## Description

Borrower repays the outstanding loan amount.

## Flow

1. Borrower repays:
   - Principal
   - Accrued interest
2. LoanManager validates the repayment amount.
3. Treasury receives the repayment.
4. LoanManager updates the loan status.
5. CollateralManager releases the locked ETH.

## Validation

Repayment amount must equal:

- Principal
- Interest

## Output

- Loan status becomes **Closed**.
- Borrower's ETH collateral is returned.

---

# 7. Price Monitoring

## Actors

- Chainlink Price Oracle

## Description

The protocol retrieves the ETH/USD price whenever required.

## MVP Implementation

Price is queried during:

- Loan approval
- Liquidation checks

Continuous monitoring is not implemented.

---

# 8. Liquidation Check

## Actors

- Automated Keeper

## Description

The keeper periodically checks whether active loans remain sufficiently collateralized.

## Flow

1. Retrieve the latest ETH price.
2. Calculate the current collateral ratio.
3. Compare it with the liquidation threshold.

## Validation

### If collateral ratio is healthy

- No action.

### If collateral ratio falls below the liquidation threshold

- Loan becomes **Eligible for Liquidation**.

---

# 9. Auction Creation

## Actors

- LiquidationAuction

## Description

The protocol creates a liquidation auction for undercollateralized loans.

## Flow

1. Auction is created.
2. Collateral is locked for auction.
3. Record:
   - Auction start time
   - Auction end time
   - Starting bid (Outstanding Debt)

## Output

- Auction becomes **Active**.

---

# 10. Bidding

## Actors

- Bidders

## Description

Participants compete by placing higher bids.

## Flow

1. Bidder submits a bid.
2. Protocol validates:
   - Bid is greater than the current highest bid.
3. Previous highest bidder is refunded.
4. New highest bid is recorded.

## Output

- Highest bid is updated.

---

# 11. Auction Settlement

## Description

The auction is finalized after the bidding period expires.

## Flow

1. Auction duration expires.
2. Highest bidder wins.
3. ETH collateral is transferred to the winning bidder.
4. Outstanding debt is transferred to the Treasury.
5. Any remaining surplus is returned to the borrower.
6. Loan status becomes **Closed**.

## Output

- Auction successfully completed.
- Treasury recovers the outstanding debt.
- Borrower receives any surplus proceeds.

---

# 12. Treasury Update

## Description

Treasury updates its internal accounting after every financial transaction.

## Treasury Updates

- Available liquidity
- Loan repayments
- Auction proceeds
- Lender deposits

---

# Future Enhancement

If the value of ETH collateral increases significantly after loan issuance:

- Borrower may request an additional loan based on the increased collateral value.
- Existing collateral remains locked.
- Automatic collateral withdrawal is **not** supported.

---

# Complete Functional Flow

```text
                Lenders
                   │
                   ▼
        Deposit Stablecoins
                   │
                   ▼
            Treasury Pool
                   │
                   ▼
      Borrower Deposits ETH
                   │
                   ▼
         Collateral Locked
                   │
                   ▼
            Request Loan
                   │
                   ▼
         Loan Validation
                   │
                   ▼
      Chainlink Price Oracle
                   │
                   ▼
           Loan Approved
                   │
                   ▼
 Treasury Transfers Stablecoins
                   │
                   ▼
             Loan Active
                   │
          ┌────────┴─────────┐
          │                  │
          ▼                  ▼
     Loan Repaid      Keeper Checks Price
          │                  │
          ▼                  ▼
Return ETH Collateral   Liquidation Check
                             │
                  Healthy? ──┴──── No
                     │              │
                    Yes             ▼
                     │      Auction Created
                     │              │
                     │              ▼
                     │       Users Place Bids
                     │              │
                     │              ▼
                     │      Auction Settlement
                     │              │
                     │              ▼
                     └────► Treasury Receives Debt
                                   │
                                   ▼
                     Borrower Receives Surplus
```