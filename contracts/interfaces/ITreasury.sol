// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

interface ITreasury {
    function transferLoan(address borrower, uint256 amount) external;
    function receiveRepayment(address borrower, uint256 principal, uint256 interest) external;
}