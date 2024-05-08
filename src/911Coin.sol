// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";
contract NineEleven is ERC20, Ownable(msg.sender) {

    uint8 private dailyBurnPercent = 2; // 2%
    uint8 private monthlyBurnPercent = 5; // 5%
    uint8 private yearlyBurnPercent = 30; // 30%
    uint8 private constant PERCENTAGE_PRECISION = 100;

    constructor() ERC20("911Coin", "911Coin") {
        _mint(msg.sender, 911911911911 * 10 ** 18);
    }

    modifier onlyBurner {
        require(msg.sender == burner, "Only burner");
        _;
    }

    function burn() external {
        _burn(owner, value);
    }

    function setBurner(address _burner) external onlyOwner {
        burner = _burner;
    }

    function daily_burn_percentage() public view returns(uint256){
        return dailyBurnPercent;
    }

    function monthly_burn_percentage() public view returns(uint256){
        return monthlyBurnPercent;
    }

    function yearly_burn_percentage() public view returns(uint256){
        return yearlyBurnPercent;
    }
}
