pragma solidity ^0.4.21;

import 'zeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol';
import 'zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol';
import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import 'zeppelin-solidity/contracts/token/ERC20/PausableToken.sol';

/**
 * @title UbexToken
 * @dev UBEX Token Smart Contract
 */
contract UbexToken is DetailedERC20, StandardToken, BurnableToken, PausableToken {

    /**
    * Init token by setting its total supply
    *
    * @param totalSupply total token supply
    */
    function UbexToken(
        uint256 totalSupply
    ) DetailedERC20(
        "UBEX Token",
        "UBEX",
        18
    ) {
        totalSupply_ = totalSupply;
        balances[msg.sender] = totalSupply;
    }
}