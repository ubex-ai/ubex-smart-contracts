pragma solidity ^0.4.23;

// common zeppelin includes
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

// ubex-related includes
import './SystemOwner.sol';
import './UbexStorage.sol';

/**
 * @title UbexExchange
 * @dev UBEX exchange main system contract
 */
contract UbexExchange {
    using SafeMath for uint256;

    // stores a list of system addresses who have access to crucial functionality
    SystemOwner public systemOwner;
    // separate contract for system data storage
    UbexStorage public store;

    event PublisherCreated(bytes16 indexed id, address indexed owner);

    // check that sender actually has access to crucial functionality
    modifier onlyOwner() {
        require(systemOwner.isOwner(msg.sender));
        _;
    }

    /**
    * @param storageAddress ethereum address of the storage smart-contract
    * @param systemOwnerAddress ethereum address of the access control smart-contract
    */
    function UbexExchange(
    address storageAddress,
    address systemOwnerAddress
    ) public {
        store = UbexStorage(storageAddress);
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
    * Set new ethereum address of the storage smart-contract
    *
    * @param storageAddress ethereum address of the storage smart-contract
    */
    function setStorageAddress(address storageAddress) public onlyOwner {
        store = UbexStorage(storageAddress);
    }

    /**
    * Create new publisher account and store its data to the system storage smart-contract
    *
    * @param id UUID of the publisher, should be unique withing a system
    * @param owner ethereum address of the publisher (actually receiver of the UBEX tokens)
    * @param name name of the publisher for visual identification by the system participants
    * @param details details of the publisher, ideally an URL with the full data available
    * @param rank initial system rank of the publisher
    * @param state initial status of the publisher (should be New in most cases)
    */
    function createPublisher(bytes16 id, address owner, string name, string details, UbexStorage.Rank rank, UbexStorage.State state) public onlyOwner {
        UbexStorage.State _state;
        (, _state) = store.users(id);
        require(_state == UbexStorage.State.Unknown);

        store.setUser(id, owner, UbexStorage.Role.Publisher, name, details, rank, state);

        emit PublisherCreated(id, owner);
    }

}