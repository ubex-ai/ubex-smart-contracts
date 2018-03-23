pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './SystemOwner.sol';

/**
 * @title UbexStorage
 * @dev smart contract used to store the main data of the UBEX exchange
 */
contract UbexStorage {
    using SafeMath for uint256;

    // the status of an entity
    enum State {Unknown, New, Active, InProgress, Finished, Rejected}
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
        // user's state
        State state;
    }

    // list of users
    mapping (bytes16 => User) public users;

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
    function UbexStorage(address systemOwnerAddress) public {
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

    /**
    * Set the user data
    * if any param comes with a default data value it will not be updated
    *
    * @param id UUID of the user
    * @param owner ethereum address of the user (actually receiver of the UBEX tokens)
    * @param role the system role of the user
    * @param name name of the user for visual identification by the system participants
    * @param details details of the user, ideally an URL with the full data available
    * @param rank system rank of the user
    * @param state status of the user (should be New in most cases)
    */
    function setUser(bytes16 id, address owner, Role role, string name, string details, Rank rank, State state) public onlyOwner {
        if (users[id].state == State.Unknown) {
            users[id] = User({
                created : now,
                owner : owner,
                role : role,
                name : name,
                details : details,
                rank : rank,
                state : state
            });
        } else {
            users[id] = User({
                created : users[id].created,
                owner : (owner == address(0)) ? users[id].owner : owner,
                role : users[id].role,
                name : (bytes(name).length == 0) ? users[id].name : name,
                details : (bytes(details).length == 0) ? users[id].details : details,
                rank : (rank == Rank.NotSet) ? users[id].rank : rank,
                state : (state == State.Unknown) ? users[id].state : state
            });
        }
    }
}