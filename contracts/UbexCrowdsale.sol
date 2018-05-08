pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

/**
 * @title UbexCrowdsale
 * @dev Crowdsale that locks tokens from withdrawal until it ends.
 */
contract UbexCrowdsale is Crowdsale {
    using SafeMath for uint256;

    mapping(address => uint256) public balances;
    bool public closed;

    /**
     * @dev Withdraw tokens only after crowdsale ends.
     */
    function withdrawTokens() public {
        require(hasClosed());
        uint256 amount = balances[msg.sender];
        require(amount > 0);
        balances[msg.sender] = 0;
        _deliverTokens(msg.sender, amount);
    }

    /**
     * @dev Overrides parent by storing balances instead of issuing tokens right away.
     * @param _beneficiary Token purchaser
     * @param _tokenAmount Amount of tokens purchased
     */
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        balances[_beneficiary] = balances[_beneficiary].add(_tokenAmount);
    }

    /**
     * @dev Checks whether the period in which the crowdsale is open has already elapsed.
     * @return Whether crowdsale period has elapsed
     */
    function hasClosed() public view returns (bool) {
        return closed;
    }

    /**
     * @dev Closes the period in which the crowdsale is open.
     */
    function closeCrowdsale(bool closed_) public onlyOwner {
        closed = closed_;
    }
}
