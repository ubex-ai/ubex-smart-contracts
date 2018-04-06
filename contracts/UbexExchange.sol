pragma solidity ^0.4.23;

// common zeppelin includes
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

// ubex-related includes
import './SystemOwner.sol';
import './UbexStorage.sol';
import './AdamCoefficients.sol';

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
    // neural network coefficients related to particular entity
    AdamCoefficients public coeff;

    event PublisherCreated(bytes16 indexed id, address indexed owner);
    event AdvertiserCreated(bytes16 indexed id, address indexed owner);
    event AdSpaceCreated(bytes16 indexed id, bytes16 indexed owner);

    // check that sender actually has access to crucial functionality
    modifier onlyOwner() {
        require(systemOwner.isOwner(msg.sender));
        _;
    }

    /**
    * @param storageAddress ethereum address of the storage smart-contract
    * @param coeffAddress ethereum address of the neural network coefficients smart-contract
    * @param systemOwnerAddress ethereum address of the access control smart-contract
    */
    function UbexExchange(
    address storageAddress,
    address coeffAddress,
    address systemOwnerAddress
    ) public {
        store = UbexStorage(storageAddress);
        coeff = AdamCoefficients(coeffAddress);
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

    /**
        * Set the existing publisher's coefficients used to tune neural network models
        *
        * @param id UUID of the publisher
        * @param coeffs a list of coefficients of int64 type (denormalise to int64 max value)
        */
    function setPublisherCoeffs(bytes16 id, int64[] coeffs) public onlyOwner {
        UbexStorage.State _state;
        (, _state) = store.users(id);
        require(_state != UbexStorage.State.Unknown);

        coeff.setCoefficients(id, coeffs);
    }

    /**
    * Get the existing publisher's coefficient used to tune neural network models
    *
    * @param id UUID of the publisher
    * @param index coefficient index
    * @return int64 value (use tanh function for normalization)
    */
    function getPublisherCoeff(bytes16 id, uint16 index) public constant returns (int64) {
        UbexStorage.State _state;
        (, _state) = store.users(id);
        require(_state != UbexStorage.State.Unknown);

        return coeff.coefficients(id, index);
    }

    /**
    * Create new advertiser account and store its data to the system storage smart-contract
    *
    * @param id UUID of the advertiser, should be unique withing a system
    * @param owner ethereum address of the advertiser (actually receiver of the UBEX tokens)
    * @param name name of the advertiser for visual identification by the system participants
    * @param details details of the advertiser, ideally an URL with the full data available
    * @param rank initial system rank of the advertiser
    * @param state initial status of the advertiser (should be New in most cases)
    */
    function createAdvertiser(bytes16 id, address owner, string name, string details, UbexStorage.Rank rank, UbexStorage.State state) public onlyOwner {
        UbexStorage.State _state;
        (, _state) = store.users(id);
        require(_state == UbexStorage.State.Unknown);

        store.setUser(id, owner, UbexStorage.Role.Advertiser, name, details, rank, state);

        emit AdvertiserCreated(id, owner);
    }

    /**
        * Set the existing advertiser's coefficients used to tune neural network models
        *
        * @param id UUID of the advertiser
        * @param coeffs a list of coefficients of int64 type (denormalise to int64 max value)
        */
    function setAdvertiserCoeffs(bytes16 id, int64[] coeffs) public onlyOwner {
        UbexStorage.State _state;
        (, _state) = store.users(id);
        require(_state != UbexStorage.State.Unknown);

        coeff.setCoefficients(id, coeffs);
    }

    /**
    * Get the existing advertiser's coefficient used to tune neural network models
    *
    * @param id UUID of the advertiser
    * @param index coefficient index
    * @return int64 value (use tanh function for normalization)
    */
    function getAdvertiserCoeff(bytes16 id, uint16 index) public constant returns (int64) {
        UbexStorage.State _state;
        (, _state) = store.users(id);
        require(_state != UbexStorage.State.Unknown);

        return coeff.coefficients(id, index);
    }

    /**
       * Create new publishing space and store its data to the system storage smart-contract
       *
       * @param id UUID of the publishing space, should be unique withing a system
       * @param owner UUID of the user who owns this space
       * @param name visual representation of the space
       * @param url URL of the website providing publishing space
       * @param details full details of the space
       * @param categories a list of advertising category ids the space can accept for publishing
       * @param state status of the advertising space
       */
    function createAdSpace(bytes16 id, bytes16 owner, string name, string url, string details, uint16[] categories, UbexStorage.State state) public onlyOwner {
        UbexStorage.State _state;
        (, _state) = store.adSpaces(id);
        require(_state == UbexStorage.State.Unknown);

        store.setAdSpace(id, owner, name, url, details, categories, state);

        emit AdSpaceCreated(id, owner);
    }
}