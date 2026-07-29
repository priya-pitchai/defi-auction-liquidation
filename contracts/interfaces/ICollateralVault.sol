//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface ICollateralVault {
    function releaseCollateral(address borrower, uint256 amount) external;
    function liquidateCollateral(address borrower, uint256 amount) external;
    function getCollateralBalance(address borrower) external view returns (uint256);
}