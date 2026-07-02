// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Treasury {

    uint256 public totalLiquidity;
    uint256 public availableLiquidity;
    uint256 public lockedLiquidity;

    address public owner;
    address public loanManager;
    
    IERC20 public stableToken;

    event LiquidityDeposited(address lender, uint256 amount);
    event LiquidityWithdrawn(address lender, uint256 amount);
    event LoanTransferred(address borrower, uint256 amount);
    event RepaymentReceived(address borrower, uint256 principal, uint256 interest);

    constructor(address _stableToken) {
        owner = msg.sender;
        stableToken = IERC20(_stableToken);
    }

    mapping (address => uint256) public lenderBalances;

    modifier onlyOwner() {
        require(owner == msg.sender, "Not owner");
        _; // Executes the function body
    }

    modifier onlyLoanManager() {
        require(msg.sender == loanManager, "Treasury: Only loan manager can call this function");
        _;
    }   

    function depositLiquidity(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(stableToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");  //Checks → Effects → Interactions
        totalLiquidity += amount;
        availableLiquidity += amount;
        lenderBalances[msg.sender] += amount;
        emit LiquidityDeposited(msg.sender, amount);
        
    }

    function withdrawLiquidity(uint256 amount) external {
        require(lenderBalances[msg.sender] >= amount, "Treasury: Insufficient balance");
        require(availableLiquidity >= amount, "Treasury: Insufficient liquidity"); 
        lenderBalances[msg.sender] -= amount;
        totalLiquidity -= amount;
        availableLiquidity -= amount;
        require(stableToken.transfer(msg.sender, amount), "Transfer failed" );   
        emit LiquidityWithdrawn(msg.sender, amount);
    }


    function transferLoan(address borrower, uint256 amount) onlyLoanManager external {
        require(amount > 0, "Amount must be greater than zero"); 
        require(availableLiquidity >= amount, "Treasury: Insufficient liquidity");
        require(borrower != address(0), "Treasury: Invalid borrower address");
        availableLiquidity -= amount;
        lockedLiquidity += amount;
        require(stableToken.transfer(borrower, amount), "Transfer failed");   //Checks → Effects → Interactions
        emit LoanTransferred(borrower, amount);
    }

    function receiveRepayment(address borrower, uint256 principal, uint256 interest) onlyLoanManager external {
        uint256 total = principal + interest;
        require(borrower != address(0), "Treasury: Invalid borrower address");
        require(principal > 0 || interest > 0, "Treasury: Principal and interest must be greater than zero");
        require(stableToken.transferFrom(borrower, address(this), total), "Transfer failed");  //Checks → Effects → Interactions
        lockedLiquidity -= principal;
        availableLiquidity += total;
        totalLiquidity += interest;
        emit RepaymentReceived(borrower, principal, interest);
    }

    function setLoanManager(address _loanManager) onlyOwner external {
        require(_loanManager != address(0), "Treasury: Invalid loan manager address");
        require(loanManager != _loanManager,"Already set");
        loanManager = _loanManager;
    }
}