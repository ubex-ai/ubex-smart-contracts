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

    // Map of all purchaiser's balances (doesn't include bounty amounts)
    mapping(address => uint256) public balances;

    // Amount of issued tokens
    uint256 public tokensIssued;

    // bonus tokens rate multiplier x1000 (i.e. 1200 is +20% = 1.2 = 1200 / 1000)
    uint256 public bonusMultiplier;

    // Is a crowdsale closed?
    bool public closed;

    /**
     * Event for token withdrawal logging
     * @param receiver who receive the tokens
     * @param amount amount of tokens sent
     */
    event TokenDelivered(address indexed receiver, uint256 amount);

    /**
    * Init crowdsale by setting its params
    *
    * @param _rate Number of token units a buyer gets per wei
    * @param _wallet Address where collected funds will be forwarded to
    * @param _token Address of the token being sold
    * @param _bonusMultiplier bonus tokens rate multiplier x1000
    */
    function UbexCrowdsale(
        uint256 _rate,
        address _wallet,
        ERC20 _token,
        uint256 _bonusMultiplier
    ) Crowdsale(
        _rate,
        _wallet,
        _token
    ) {
        bonusMultiplier = _bonusMultiplier;
    }

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
        tokensIssued = tokensIssued.add(_tokenAmount);
    }

    /**
   * @dev Overrides the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        return _weiAmount.mul(rate).mul(bonusMultiplier).div(1000);
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
     * @dev set the bonus multiplier.
     */
    function setBonusMultiplier(uint256 bonusMultiplier_) public onlyOwner {
        bonusMultiplier = bonusMultiplier_;
    }

    /**
     * @dev Withdraw tokens excess on the contract after crowdsale.
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
        emit TokenDelivered(receiver_, amount);
        _deliverTokens(receiver_, amount);
    }
}
