// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MyToken is ERC20, Ownable, ERC20Permit {
    constructor(
        address initialOwner
    ) ERC20("MyToken", "MTK") Ownable(initialOwner) ERC20Permit("MyToken") {}

    bytes32 public merkleRoot;
    mapping(address => bool) public hasClaimed;
    address public daoAddress;

    function mint(uint256 amount, bytes32[] calldata merkleProof) external {
        require(!hasClaimed[msg.sender], "Already claimed");

        // Check merkle proof
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
        require(
            MerkleProof.verify(merkleProof, merkleRoot, leaf),
            "Invalid proof"
        );

        // Calculate distributions
        uint256 userAmount = (amount * 70) / 100;
        uint256 daoAmount = (amount * 20) / 100;
        uint256 ownerAmount = amount - userAmount - daoAmount;

        // Mark address as having claimed
        hasClaimed[msg.sender] = true;

        // Mint tokens in a single call
        _mintMultiple(
            msg.sender,
            userAmount,
            daoAddress,
            daoAmount,
            owner(),
            ownerAmount
        );
    }

    // Helper function to mint multiple recipients in one transaction
    function _mintMultiple(
        address user,
        uint256 userAmount,
        address dao,
        uint256 daoAmount,
        address ownerAddr,
        uint256 ownerAmount
    ) internal {
        _mint(user, userAmount);
        _mint(dao, daoAmount);
        _mint(ownerAddr, ownerAmount);
    }

    // Function to set DAO address, onlyOwner ensures proper security
    function setDaoAddress(address _daoAddress) external onlyOwner {
        daoAddress = _daoAddress;
    }

    // Public helper function for generating leaf
    function getLeaf(uint256 amount) public view returns (bytes32) {
        return keccak256(abi.encodePacked(msg.sender, amount));
    }

    // Set merkle root with onlyOwner protection
    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    // Function to verify Merkle proof, simplified for easier gas handling
    function verifyRoot(
        bytes32[] calldata _merkleProof,
        uint256 amount
    ) external view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
        return MerkleProof.verify(_merkleProof, merkleRoot, leaf);
    }

    // Modifier for proof verification (can be used for specific minter restrictions)
    modifier onlyMinters(bytes32[] calldata _merkleProof, uint256 amount) {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
        require(
            MerkleProof.verify(_merkleProof, merkleRoot, leaf),
            "Not a valid minter"
        );
        _;
    }
}
