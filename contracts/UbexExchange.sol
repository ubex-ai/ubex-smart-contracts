pragma solidity ^0.4.23;

// common zeppelin includes
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

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

    // the role of the user
    enum Role {Undefined, Publisher, Advertiser}

    // user's data structure
    struct User {
        // unix timestamp
        uint created;
        // ethereum address of the user
        address owner;
        // the role of the user
        Role role;
        // name of the user
        string name;
        // details of the user (ideally URL to the full details)
        string details;
    }

    // check that sender actually has access to crucial functionality
    modifier onlyOwner() {
        require(systemOwner.isOwner(msg.sender));
        _;
    }

    // list of users
    mapping (bytes16 => User) public users;

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