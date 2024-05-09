// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/utils/ReentrancyGuard.sol";
import {IUniswapV2Factory} from "lib/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from "lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract NineEleven is ERC20, Ownable(msg.sender), ReentrancyGuard {
    uint8 private dailyBurnPercent = 2; //2%
    uint8 private monthlyBurnPercent = 5; //5%
    uint8 private yearlyBurnPercent = 30; //30%
    uint8 private buyFee = 5; //5%
    uint8 private sellFee = 10; //10%
    uint8 private constant PERCENTAGE_PRECISION = 100;
    uint256 private taxPausePeriod = 365 days * 5;
    uint256 private burnPausePeriod = 365 days * 5;

    address private marketingWallet;

    // Pancakeswap variables
    IUniswapV2Factory public constant PANCAKESWAP_FACTORY =
        IUniswapV2Factory(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    // IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73); // bsc_mainnet

    IUniswapV2Router02 public constant PANCAKESWAP_ROUTER =
        IUniswapV2Router02(0x9A082015c919AD0E47861e5Db9A1c7070E81A2C7);
    // IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // bsc_mainnet

    address public immutable PANCAKESWAP_V2_PAIR;

    error BURN_PAUSED();

    constructor() ERC20("911Coin", "911Coin") {
        _mint(msg.sender, 911911911911 * 10 ** 18);
        PANCAKESWAP_V2_PAIR = PANCAKESWAP_FACTORY.createPair(
            address(this),
            PANCAKESWAP_ROUTER.WETH()
        );
    }

    function transfer(
        address to,
        uint256 value
    ) public override nonReentrant returns (bool) {
        address owner = owner();
        address from = _msgSender();
        if (from == owner || to == owner) {
            super._update(from, to, value);
        } else {
            uint256 transferableAmount = calculate_and_deduct_tax(
                from,
                to,
                value
            );
            _transfer(from, to, transferableAmount);
        }
        return true;
    }

    /**
    @dev calculate tax
    @param from sender adddress
    @param to receiver address
    @param amount amount of tokens to transfer
     */
    function calculate_and_deduct_tax(
        address from,
        address to,
        uint256 amount
    ) private returns (uint256) {
        if (block.timestamp > taxPausePeriod) return amount;
        uint256 _totalSupply = totalSupply();
        if (from == PANCAKESWAP_V2_PAIR) {
            uint256 _marketingTax = (_totalSupply * 3) / PERCENTAGE_PRECISION;
            uint256 _burnTax = (_totalSupply * 2) / PERCENTAGE_PRECISION;
            _burn(msg.sender, _burnTax);
            _transfer(msg.sender, marketingWallet, _marketingTax);
            return amount - (_marketingTax + _burnTax);
        } else if (to == PANCAKESWAP_V2_PAIR) {
            uint256 _marketingTax = (_totalSupply * 5) / PERCENTAGE_PRECISION;
            uint256 _burnTax = (_totalSupply * 5) / PERCENTAGE_PRECISION;
            _burn(msg.sender, _burnTax);
            _transfer(msg.sender, marketingWallet, _marketingTax);
            return amount - (_marketingTax + _burnTax);
        }
        return amount;
    }

    function burn(uint256 _amount) external onlyOwner nonReentrant {
        if(block.timestamp > burnPausePeriod) revert BURN_PAUSED();
        address owner = owner();
        _burn(owner, _amount);
    }

    function set_marketing_wallet(
        address new_marketing_wallet
    ) external onlyOwner {
        marketingWallet = new_marketing_wallet;
    }

    function daily_burn_percentage() public view returns (uint256) {
        return dailyBurnPercent;
    }

    function monthly_burn_percentage() public view returns (uint256) {
        return monthlyBurnPercent;
    }

    function yearly_burn_percentage() public view returns (uint256) {
        return yearlyBurnPercent;
    }

    function marketing_wallet() public view returns (address) {
        return marketingWallet;
    }

    function buy_fee() public view returns (uint8) {
        return buyFee;
    }

    function sell_fee() public view returns (uint8) {
        return sellFee;
    }

    function burn_pause_period() public view returns (uint256) {
        return burnPausePeriod;
    }

    function tax_pause_period() public view returns (uint256) {
        return taxPausePeriod;
    }
}
