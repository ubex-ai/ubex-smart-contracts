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

    // publishing space data structure
    struct AdSpace {
        // unix timestamp
        uint created;
        // the UUID of the user who owns this space
        bytes16 owner;
        // visual representation of the space
        string name;
        // the URL of the website providing publishing space
        string url;
        // the full details of the space
        string details;
        // a list of advertising category ids the space can accept for publishing
        uint16[] categories;
        // publishing space state
        State state;
    }

    // list of users
    mapping (bytes16 => User) public users;
    // list of advertising spaces
    mapping (bytes16 => AdSpace) public adSpaces;

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

    /**
    * Set the advertising space data
    * if any param comes with a default data value it will not be updated
    *
    * @param id UUID of the advertising space
    * @param owner UUID of the user who owns this space
    * @param name visual representation of the space
    * @param url URL of the website providing publishing space
    * @param details full details of the space
    * @param categories a list of advertising category ids the space can accept for publishing
    * @param state status of the advertising space
    */
    function setAdSpace(bytes16 id, bytes16 owner, string name, string url, string details, uint16[] categories, State state) public onlyOwner {
        if (adSpaces[id].state == State.Unknown) {
            adSpaces[id] = AdSpace({
            created : now,
            owner : owner,
            name : name,
            url : url,
            details : details,
            categories : categories,
            state : state
            });
        } else {
            adSpaces[id] = AdSpace({
            created : adSpaces[id].created,
            owner : (owner.length == 0) ? adSpaces[id].owner : owner,
            name : (bytes(name).length == 0) ? adSpaces[id].name : name,
            url : (bytes(url).length == 0) ? adSpaces[id].url : url,
            details : (bytes(details).length == 0) ? adSpaces[id].details : details,
            categories : (categories.length == 0) ? adSpaces[id].categories : categories,
            state : (state == State.Unknown) ? adSpaces[id].state : state
            });
        }
    }
}