pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

/**
 * @title SystemOwner
 * @dev smart contract used to maintain system owner ethereum addresses
 */
contract SystemOwner is Ownable {
    // a list of system owners' addresses
    mapping (uint16 => address) public owners;
    // a number of owners
    uint16 ownersCount;

    /**
    * Add new owner to the list of system owners
    *
    * @param owner ethereum address of the owner
    */
    function addOwner(address owner) public onlyOwner {
        owners[ownersCount] = owner;
        ownersCount++;
    }

    /**
    * Set the existing system owner's ethereum address
    *
    * @param i an index of existing system owner
    * @param owner new ethereum address of the owner
    */
    function setOwner(uint16 i, address owner) public onlyOwner {
        require(owners[i] == address(0));
        owners[i] = owner;
    }

    /**
    * Delete the existing system owner's ethereum address from the list of system owners
    *
    * @param i an index of existing system owner
    */
    function deleteOwner(uint16 i) public onlyOwner {
        require(owners[i] != address(0));
        owners[i] = address(0);
    }

    /**
    * Check that provided ethereum address is a system owner address
    *
    * @param owner ethereum address of the checking sender
    */
    function isOwner(address owner) public returns (bool) {
        require(owner != address(0));

        for (uint16 i = 0; i < ownersCount; i++) {
            address _owner = owners[i];
            if (_owner == owner) {
                return true;
            }
        }

        return false;
    }
}