# Loan State Diagram

## Purpose

The state diagram describes the lifecycle of a loan from creation until closure.

It defines:

- Valid state transitions
- Invalid transitions
- Business rules governing each state

---

## Loan Lifecycle

```text
                  +-------------+
                  |  Requested  |
                  +-------------+
                         |
                         v
                  +-------------+
                  |  Approved   |
                  +-------------+
                         |
                         v
                  +-------------+
                  |   Active    |
                  +-------------+
                   /           \
                  /             \
                 v               v
        +---------------+   +----------------------+
        |    Repaid     |   | Eligible For         |
        |               |   | Liquidation          |
        +---------------+   +----------------------+
                 |                    |
                 |                    v
                 |          +----------------+
                 |          | Auction Active |
                 |          +----------------+
                 |                    |
                 |                    v
                 |          +-------------------+
                 |          | Auction Settled   |
                 |          +-------------------+
                 |                    |
                 +----------->+---------------+
                              |    Closed     |
                              +---------------+
```

---

## State Descriptions

### Requested

- Borrower submits a loan request.
- Loan validation has not yet been completed.

---

### Approved

- Loan satisfies all business rules.
- Treasury is ready to transfer funds.

---

### Active

- Stablecoins have been disbursed.
- Interest accrues.
- Collateral remains locked.

---

### Repaid

- Borrower repays the full principal and interest.
- Collateral is released.

---

### Eligible for Liquidation

- Collateral ratio falls below the liquidation threshold.
- Loan is marked for liquidation.

---

### Auction Active

- Auction is created.
- Bidders compete for collateral.

---

### Auction Settled

- Auction has ended.
- Winning bidder receives collateral.
- Treasury receives repayment.
- Surplus (if any) is returned to the borrower.

---

### Closed

Terminal state.

The loan has been successfully repaid or liquidated.