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

    function mint(
        address to,
        uint256 amount,
        bytes32[] calldata _merkleProof
    ) public onlyMinters(_merkleProof) {
        _mint(to, amount);
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function verifyRoot(
        bytes32[] calldata _merkleProof
    ) public view returns (bool) {
        return (
            MerkleProof.verifyCalldata(
                _merkleProof,
                merkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            )
        );
    }

    modifier onlyMinters(bytes32[] calldata _merkleProof) {
        require(
            MerkleProof.verifyCalldata(
                _merkleProof,
                merkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "not Minter"
        );
        _;
    }
}
