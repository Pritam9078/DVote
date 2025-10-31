// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title GovernanceToken
 * @dev ERC20 token with voting, delegation, permit, and role-based mint/burn access.
 * Allows custom name and symbol during deployment.
 */
contract GovernanceToken is ERC20, ERC20Burnable, ERC20Permit, ERC20Votes, AccessControl {
    uint256 public constant MAX_SUPPLY = 1_000_000 * 10**18; // Max 1M tokens
    uint256 public constant MINT_COOLDOWN = 1 days;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public lastMintTime;
    bool public autoDelegationEnabled = true;

    event TokensMinted(address indexed to, uint256 amount, uint256 timestamp);
    event AutoDelegationToggled(bool enabled);
    event DelegationAssisted(address indexed delegator, address indexed delegatee);

    /**
     * @dev Deploy with a custom name/symbol and initial admin + mint amount.
     * @param name_ Token name
     * @param symbol_ Token symbol
     * @param admin Admin address with special roles
     * @param initialMint Initial token supply to mint to admin
     */
    constructor(
        string memory name_,
        string memory symbol_,
        address admin,
        uint256 initialMint
    )
        ERC20(name_, symbol_)
        ERC20Permit(name_)
    {
        require(admin != address(0), "Invalid admin address");

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);

        if (initialMint > 0) {
            _mint(admin, initialMint);
            _delegate(admin, admin);
            emit TokensMinted(admin, initialMint, block.timestamp);
        }

        lastMintTime = block.timestamp;
    }

    /**
     * @dev Mint new tokens (MINTER_ROLE only for better security)
     */
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be > 0");
        require(totalSupply() + amount <= MAX_SUPPLY, "Cap exceeded");
        require(block.timestamp >= lastMintTime + MINT_COOLDOWN, "Mint cooldown active");

        _mint(to, amount);
        lastMintTime = block.timestamp;

        if (autoDelegationEnabled && delegates(to) == address(0)) {
            _delegate(to, to);
        }

        emit TokensMinted(to, amount, block.timestamp);
    }

    /**
     * @dev Burn tokens (ADMIN_ROLE only)
     */
    function burn(address from, uint256 amount) external onlyRole(ADMIN_ROLE) {
        _burn(from, amount);
    }

    /**
     * @dev Toggle automatic delegation
     */
    function setAutoDelegation(bool enabled) external onlyRole(ADMIN_ROLE) {
        autoDelegationEnabled = enabled;
        emit AutoDelegationToggled(enabled);
    }

    /**
     * @dev Delegate voting power manually
     */
    function delegateVotes(address delegatee) external {
        require(delegatee != address(0), "Cannot delegate to zero address");
        _delegate(msg.sender, delegatee);
        emit DelegationAssisted(msg.sender, delegatee);
    }

    // -------- Overrides --------

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Votes)
    {
        super._update(from, to, value);
        if (autoDelegationEnabled && to != address(0) && delegates(to) == address(0) && balanceOf(to) > 0) {
            _delegate(to, to);
        }
    }

    function nonces(address owner)
        public
        view
        override(ERC20Permit, Nonces)
        returns (uint256)
    {
        return super.nonces(owner);
    }

    function clock() public view override returns (uint48) {
        return uint48(block.timestamp);
    }

    function CLOCK_MODE() public pure override returns (string memory) {
        return "mode=timestamp";
    }

    // -------- Helper Views --------

    function getTokenInfo()
        external
        view
        returns (
            string memory tokenName,
            string memory tokenSymbol,
            uint8 tokenDecimals,
            uint256 supply,
            uint256 maxSupply
        )
    {
        return (name(), symbol(), decimals(), totalSupply(), MAX_SUPPLY);
    }

    function canMint() external view returns (bool) {
        return block.timestamp >= lastMintTime + MINT_COOLDOWN;
    }

    function remainingMintableSupply() external view returns (uint256) {
        return MAX_SUPPLY - totalSupply();
    }
}
