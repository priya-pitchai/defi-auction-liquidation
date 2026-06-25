1. Treasury is funded.
2. Borrower deposits ETH as collateral.
3. Borrower requests a loan.
4. LoanManager validates collateral.
5. PriceOracle returns the ETH price.
6. LoanManager calculates the maximum loan amount.
7. Treasury transfers funds to the borrower.
8. Borrower repays principal + interest.
9. Treasury receives repayment.
10. If collateral value falls below the liquidation threshold, the auction process begins.