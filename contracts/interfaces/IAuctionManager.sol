//SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

interface IAuctionManager {
    function startAuction(address borrower, uint256 collateralAmount, uint256 loanAmount) external;
}