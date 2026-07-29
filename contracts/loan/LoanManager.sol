// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../interfaces/ITreasury.sol";
import "../interfaces/ICollateralVault.sol";
import "../interfaces/IPriceOracle.sol";
import "../interfaces/IAuctionManager.sol";

contract LoanManager {

    uint256 public constant MAX_LTV = 70;
    uint256 public constant LIQUIDATION_THRESHOLD = 80;
    uint256 public constant ANNUAL_INTEREST_RATE = 5; // Example interest rate
    uint256 public constant HEALTH_FACTOR_PRECISION = 1e18; //1e18 is 1*10^18 = 18 decimals 1
    uint256 public constant LOAN_DURATION = 30 days;

    ITreasury public treasury;
    ICollateralVault public collateralVault;
    IPriceOracle public priceOracle;
    IAuctionManager public auctionManager;

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "LoanManager: Only owner can call this function");
        _;
    }

    constructor(address _treasury,address _collateralVault,address _priceOracle, address _auctionManager) {
        owner = msg.sender;
        require(_treasury != address(0), "Invalid treasury");
        require(_collateralVault != address(0), "Invalid vault");
        require(_priceOracle != address(0), "Invalid oracle");
        require(_auctionManager != address(0), "Invalid auction manager");
        treasury = ITreasury(_treasury);
        collateralVault = ICollateralVault(_collateralVault);
        priceOracle = IPriceOracle(_priceOracle);
        auctionManager = IAuctionManager(_auctionManager);
    }

    struct Loan {
        uint256 loanAmount;
        uint256 collateralAmountEth;
        uint256 interestRate;
        uint256 loanDuration;
        uint256 loanStartTime;
        bool isActive;
    }
    mapping (address => Loan) public borrowerLoans;

    event LoanCreated(address borrower, uint256 amount);
    event LoanRepaid(address borrower, uint256 amount);
    event CollateralReleased(address borrower, uint256 amount);
    event AuctionStarted(address borrower);

    function createLoan(address borrower, uint256 amount) external onlyOwner {
        // Logic to create a loan for the borrower
        // This would involve checking collateral, calculating interest, and updating state
        require(!borrowerLoans[borrower].isActive, "LoanManager: Borrower already has an active loan");
        uint256 collateralBalanceETH = collateralVault.getCollateralBalance(borrower);
        require(collateralBalanceETH > 0, "LoanManager: No collateral deposited");
        uint256 collateralValueUSD = _getCollateralValueUSD(collateralBalanceETH);
        require(collateralValueUSD > 0, "LoanManager: Invalid collateral value"); 
        require(amount > 0, "LoanManager: Loan amount must be greater than zero");
        require(amount <= ((collateralValueUSD) * MAX_LTV) / 100, "LoanManager: Loan amount exceeds maximum LTV");
        
        borrowerLoans[borrower] = Loan({
            loanAmount: amount,
            collateralAmountEth: collateralBalanceETH,
            interestRate: ANNUAL_INTEREST_RATE, // Example interest rate
            loanDuration: LOAN_DURATION, // Example loan duration
            loanStartTime: block.timestamp,
            isActive: true
        });

        loanDistribution(borrower, amount);
        emit LoanCreated(borrower, amount); 
    }

    function _getETHPriceUSD() internal view returns (uint256) {
        return priceOracle.getLatestPrice();
    }

    function _getCollateralValueUSD(uint256 collateralBalanceEth) internal view returns (uint256) {
        uint256 ETHPriceUSD = _getETHPriceUSD();
        return (collateralBalanceEth * ETHPriceUSD) / 1e8; // Assuming price oracle returns price with 8 decimals
    }

    function calculateHealthFactor(address borrower) public view returns (uint256) {
        // Logic to calculate health factor based on collateral and loan amount
        require(borrowerLoans[borrower].isActive, "LoanManager: No active loan for borrower");
        uint256 loanValue = borrowerLoans[borrower].loanAmount;
        require(loanValue > 0, "LoanManager: Loan value is zero");
        uint256 healthFactor = (_getCollateralValueUSD(borrowerLoans[borrower].collateralAmountEth) * LIQUIDATION_THRESHOLD * HEALTH_FACTOR_PRECISION) / (loanValue*100);
        return healthFactor; 
    }


    function calculateInterest(address borrower) public view returns (uint256) {
        // Logic to calculate interest based on loan amount and duration
        require(borrowerLoans[borrower].isActive, "LoanManager: No active loan for borrower");
        uint256 interest = (borrowerLoans[borrower].loanAmount * borrowerLoans[borrower].interestRate * (block.timestamp - borrowerLoans[borrower].loanStartTime)) / (100 * 365 days);
        return interest; // Placeholder return value
    }

    function loanDistribution(address borrower, uint256 amount) private {
        // Logic to distribute loan amount to borrower
        require(borrowerLoans[borrower].isActive, "LoanManager: No active loan for borrower");
        require(amount <= borrowerLoans[borrower].loanAmount, "LoanManager: Amount exceeds loan amount");
        treasury.transferLoan(borrower, amount);
    }

    function repayLoan(address borrower, uint256 amount) external {
        // Logic to handle loan repayment
        require(msg.sender == borrower, "LoanManager: Only borrower can repay the loan");
        require(borrowerLoans[borrower].isActive, "LoanManager: No active loan for borrower");
        uint256 interest = calculateInterest(borrower);
        uint256 totalRepayment = borrowerLoans[borrower].loanAmount + interest;
        require(amount >= totalRepayment, "LoanManager: Repayment amount is less than total due");
        treasury.receiveRepayment(borrower, borrowerLoans[borrower].loanAmount, interest);
        closeLoan(borrower);
        emit LoanRepaid(borrower, amount);
    }

    function closeLoan(address borrower) internal {
        // Logic to close the loan and release collateral
        require(borrowerLoans[borrower].isActive, "LoanManager: No active loan for borrower");
        require(borrowerLoans[borrower].loanAmount > 0, "LoanManager: No active loan for borrower");
        collateralVault.releaseCollateral(borrower, borrowerLoans[borrower].collateralAmountEth);
        emit CollateralReleased(borrower, borrowerLoans[borrower].collateralAmountEth);
        delete borrowerLoans[borrower];
    }

    function auctionCollateral(address borrower) external onlyOwner {
        // Logic to auction collateral if health factor is below threshold
        require(borrowerLoans[borrower].isActive, "LoanManager: No active loan for borrower");
        bool unhealthy = calculateHealthFactor(borrower) < HEALTH_FACTOR_PRECISION;
        bool expired = block.timestamp > borrowerLoans[borrower].loanStartTime + borrowerLoans[borrower].loanDuration;
        require(unhealthy || expired, "LoanManager: Loan is healthy and not expired");
        auctionManager.startAuction(borrower, borrowerLoans[borrower].collateralAmountEth, borrowerLoans[borrower].loanAmount);
        emit AuctionStarted(borrower);
    }

    
}