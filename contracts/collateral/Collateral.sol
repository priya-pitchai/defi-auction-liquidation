// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

contract CollateralVault {

    address public loanManager;
    address public owner;
    uint256 public totalCollateral;

    struct Collateral {
        uint256 amount;
    }

    mapping(address => Collateral) public collateralBalances;

    modifier onlyLoanManager {
        require(msg.sender == loanManager, "withdrawCollateral: Only loan manager can call this function");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    event CollateralDeposited(address borrower, uint256 amount);
    event CollateralReleased(address borrower, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function setLoanManager(address _loanManager) external onlyOwner {
        require(_loanManager != address(0), "Invalid loan manager address");
        loanManager = _loanManager;
    }

    function depositCollateral() external payable{
        // Logic to deposit collateral
        require(msg.value > 0, "Invalid collateral amount");
        _depositCollateral(msg.value, msg.sender);
    }

    function releaseCollateral(address borrower, uint256 amount) external onlyLoanManager {
        // Logic to release collateral
        require(collateralBalances[borrower].amount >= amount, "Insufficient collateral");
        collateralBalances[borrower].amount -= amount;
        totalCollateral -= amount;
        transferETH(borrower, amount);
        emit CollateralReleased(borrower, amount);
    }

    function transferETH(address borrower, uint256 amount) internal{
        // Logic to transfer collateral to borrower
        // This could involve interacting with an ERC20 token contract or other mechanisms
        (bool success,) = borrower.call{value: amount}("");
        require(success, "Failed to transfer collateral");
    }

    function addOnCollateral() external payable {
        require(msg.value > 0, "Invalid collateral amount");
        _depositCollateral(msg.value, msg.sender);
    }

    function _depositCollateral(uint256 amount, address borrower) internal {
        collateralBalances[borrower].amount += amount;
        totalCollateral += amount;
        emit CollateralDeposited(borrower, amount);
    }

    function liquidateCollateral(address borrower) external onlyLoanManager{
        // Logic to liquidate collateral if the borrower defaults or if the collateral value falls below a certain threshold
        //transferCollateral(borrower, collateralToLiquidate);
    }
}