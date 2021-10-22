// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title RevocationList
 * @dev Handle Revocation List with Cryptographic accumulator
 */
contract Storage {
    address private owner;
    uint256 currentProofProduct; // this is the product of all valid certs
    uint256[] factors;
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }
    
    function setCurrentProofProduct (uint256 value) public isOwner {
        currentProofProduct = value;
    }
    
    // called to update the list of factors. Thus it will be called initially but also everytime a revocation occurred
    function populateFactors (uint256[] calldata credentialFactors) public isOwner {
        factors = credentialFactors;
    }
    
    // called by prover
    function proveNonRevocation (uint256 index) public view returns (bool) {
        uint256 proofProductWithProverIndex = calculateProofProductWith(index);
        return proofProductWithProverIndex == currentProofProduct;
    }
    
    function calculateProofProductWith (uint256 index) private view returns (uint256) {
        uint256 product = 1;
        for (uint16 i; i < factors.length; i++) {
            if (factors[i] != index) {
                product *= factors[i]; 
            }
        }
        return product * index;
    }
}

