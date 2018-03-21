pragma solidity ^0.4.23;

// common zeppelin includes
import './zeppelin/math/SafeMath.sol';

// ubex-related includes
import './SystemOwner.sol';

/**
 * @title UbexExchange
 * @dev UBEX exchange main system contract
 */
contract UbexExchange {
    using SafeMath for uint256;

    // stores a list of system addresses who have access to crucial functionality
    SystemOwner public systemOwner;

    // check that sender actually has access to crucial functionality
    modifier onlyOwner() {
        require(systemOwner.isOwner(msg.sender));
        _;
    }

    /**
    * @param systemOwnerAddress ethereum address of the access control smart-contract
    */
    function UbexExchange(
        address systemOwnerAddress
    ) public {
        systemOwner = SystemOwner(systemOwnerAddress);
    }

    /**
    * Set new ethereum address of the access control smart-contract
    *
    * @param systemOwnerAddress ethereum address of the access control smart-contract
    */
    function setSystemOwner(address systemOwnerAddress) public onlyOwner {
        systemOwner = SystemOwner(systemOwnerAddress);
    }

}