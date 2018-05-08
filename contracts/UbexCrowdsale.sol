pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

/**
 * @title UbexCrowdsale
 * @dev Crowdsale that locks tokens from withdrawal until it ends.
 */
contract UbexCrowdsale is Crowdsale, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) public balances;
    bool public closed;

    /**
     * @dev Withdraw tokens only after crowdsale ends.
     */
    function withdrawTokens() public {
        _withdrawTokensFor(msg.sender);
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
     * @dev Deliver tokens to receiver_ after crowdsale ends.
     */
    function withdrawTokensFor(address receiver_) public onlyOwner {
        _withdrawTokensFor(receiver_);
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

    /**
     * @dev Withdraw tokens axcess on the contract after crowdsale.
     */
    function postCrowdsaleWithdraw(uint256 _tokenAmount) public onlyOwner {
        token.transfer(wallet, _tokenAmount);
    }

    /**
     * @dev Withdraw tokens for receiver_ after crowdsale ends.
     */
    function _withdrawTokensFor(address receiver_) internal {
        require(hasClosed());
        uint256 amount = balances[receiver_];
        require(amount > 0);
        balances[receiver_] = 0;
        _deliverTokens(receiver_, amount);
    }
}
