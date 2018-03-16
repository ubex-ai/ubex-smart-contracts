pragma solidity ^0.4.23;

import './SystemOwner.sol';

/**
 * @title AdamCoefficients
 * @dev smart contract used to store neural network coefficients used to tune neural models
 */
contract AdamCoefficients {
    // a list of coefficients grouped by UUID of related entity
    mapping (bytes16 => mapping (uint16 => int64)) public coefficients;


    /**
    * @param systemOwnerAddress ethereum address of the access control smart-contract
    */
    function AdamCoefficients(address systemOwnerAddress) public {
        systemOwner = SystemOwner(systemOwnerAddress);
    }


    /**
    * Set the related entity coefficients used to tune neural network models
    *
    * @param id UUID of the related entity
    * @param coeffs a list of coefficients of int64 type (denormalise to int64 max value)
    */
    function setCoefficients(bytes16 id, int64[] coeffs) public onlyOwner {
        for (uint i = 0; i < coeffs.length; i++) {
            coefficients[id][uint16(i)] = coeffs[i];
        }
    }
}