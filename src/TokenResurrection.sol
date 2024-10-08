// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract TokenResurrection is Ownable, Pausable {
    IERC20 public token; // The token to be airdropped
    bytes32 public merkleRoot; // The root of the merkle tree
    string public ipfsHash;
    mapping(address => bool) public hasClaimed; // Tracks if an address has already claimed

    event rootUpdated(bytes32 indexed merkleRoot);
    event TokensClaimed(address indexed claimant, uint256 amount);
    event BatchTokensClaimed(address indexed claimer, uint256 count);
    event AirdropFunded(uint256 amount);
    event ContractPaused(bool paused, string reason);

    constructor(address _token) Ownable(msg.sender) {
        token = IERC20(_token);
    }

    /// @notice Sets the merkle root for the airdrop
    /// @param _merkleRoot The new merkle root to be set
    function updateMerkleRoot(
        bytes32 _merkleRoot,
        string calldata _ipfsHash
    ) external onlyOwner {
        merkleRoot = _merkleRoot;
        ipfsHash = _ipfsHash;
        emit rootUpdated(_merkleRoot);
    }

    /// @notice Allows users to claim their tokens based on the merkle proof
    /// @param amount The amount of tokens being claimed
    /// @param merkleProof The merkle proof to verify the claim
    function claimTokens(
        address claimant,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external whenNotPaused {
        _claim(claimant, amount, merkleProof);
    }

    /// @notice Batch claim for multiple recipients by a single user
    /// @param claimants The array of addresses to claim for
    /// @param amounts The array of token amounts corresponding to each claimant
    /// @param merkleProofs The array of merkle proofs corresponding to each claimant
    function batchClaimTokens(
        address[] calldata claimants,
        uint256[] calldata amounts,
        bytes32[][] calldata merkleProofs
    ) external whenNotPaused {
        require(
            claimants.length == amounts.length &&
                claimants.length == merkleProofs.length,
            "Array lengths mismatch"
        );

        uint256 count = claimants.length;

        for (uint256 i = 0; i < count; i++) {
            _claim(claimants[i], amounts[i], merkleProofs[i]);
        }

        emit BatchTokensClaimed(msg.sender, count);
    }

    /// @notice Internal function to handle the claim logic
    /// @param claimant The address of the claimant
    /// @param amount The amount of tokens to be claimed
    /// @param merkleProof The merkle proof for verification
    function _claim(
        address claimant,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) internal {
        require(!hasClaimed[claimant], "Airdrop already claimed");
        require(
            verifyClaim(claimant, amount, merkleProof),
            "Invalid merkle proof"
        );

        hasClaimed[claimant] = true;
        require(token.transfer(claimant, amount), "Token transfer failed");

        emit TokensClaimed(claimant, amount);
    }

    /// @notice Verifies the claim using the provided merkle proof
    /// @param claimant The address of the claimant
    /// @param amount The amount of tokens to be claimed
    /// @param merkleProof The merkle proof for verification
    /// @return True if the claim is valid, false otherwise
    function verifyClaim(
        address claimant,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(claimant, amount));
        return MerkleProof.verify(merkleProof, merkleRoot, leaf);
    }

    function hasUserClaimed(address user) external view returns (bool) {
        return hasClaimed[user];
    }

    /// @notice Fund the contract with the token to be airdropped
    /// @param amount The amount of tokens to fund the contract with
    function fundAirdrop(uint256 amount) external onlyOwner {
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Funding failed"
        );
        emit AirdropFunded(amount);
    }

    /// @notice Withdraw unclaimed tokens after the airdrop ends
    /// @param amount The amount of tokens to withdraw
    function withdrawUnclaimed(uint256 amount) external onlyOwner {
        require(token.transfer(msg.sender, amount), "Token transfer failed");
    }

    /// @notice Pause the contract to stop all claims in case of a dispute or other issues
    /// @param reason The reason for pausing the contract
    function pause(string calldata reason) external onlyOwner {
        _pause();
        emit ContractPaused(true, reason);
    }

    /// @notice Resume the contract to allow claims to continue after resolution of a dispute
    /// @param reason The reason for resuming the contract
    function unpause(string calldata reason) external onlyOwner {
        _unpause();
        emit ContractPaused(false, reason);
    }

    /// @notice Rescue any ERC20 tokens mistakenly sent to this contract
    /// @param _token The address of the ERC20 token to rescue
    /// @param amount The amount of tokens to rescue
    /// @param _recipient The recipient to send tokens to
    function rescueERC20(
        address _token,
        address _recipient,
        uint256 amount
    ) external onlyOwner {
        IERC20(_token).transfer(_recipient, amount);
    }

    /// @notice Rescue any ERC721 tokens mistakenly sent to this contract
    /// @param _token The address of the ERC721 token to rescue
    /// @param tokenId The token ID of the ERC721 to rescue
    /// @param _recipient The recipient to send tokens to
    function rescueERC721(
        address _token,
        address _recipient,
        uint256 tokenId
    ) external onlyOwner {
        IERC721(_token).safeTransferFrom(address(this), _recipient, tokenId);
    }
}
