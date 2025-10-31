// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title DAO Treasury
/// @notice Safely stores ETH & ERC20 tokens, managed by DAO (owner)
contract Treasury is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    event DepositedETH(address indexed from, uint256 amount);
    event WithdrawnETH(address indexed to, uint256 amount);
    event DepositedERC20(address indexed token, address indexed from, uint256 amount);
    event WithdrawnERC20(address indexed token, address indexed to, uint256 amount);
    event WithdrawalQueued(uint256 indexed withdrawalId, address indexed recipient, uint256 amount, uint256 unlockTime);
    event WithdrawalExecuted(uint256 indexed withdrawalId, address indexed recipient, uint256 amount);
    event WithdrawalCancelled(uint256 indexed withdrawalId);
    event WithdrawalDelayUpdated(uint256 oldDelay, uint256 newDelay);

    struct QueuedWithdrawal {
        address recipient;
        uint256 amount;
        uint256 unlockTime;
        bool executed;
        bool cancelled;
    }

    uint256 public withdrawalDelay = 1 days; // Timelock delay
    uint256 public withdrawalCount;
    mapping(uint256 => QueuedWithdrawal) public queuedWithdrawals;

    uint256 public constant MIN_WITHDRAWAL_DELAY = 1 hours;
    uint256 public constant MAX_WITHDRAWAL_DELAY = 30 days;

    constructor(address initialOwner) Ownable(initialOwner) {
        require(initialOwner != address(0), "Invalid owner address");
    }

    // -------- ETH Handling --------
    receive() external payable {
        emit DepositedETH(msg.sender, msg.value);
    }

    function deposit() external payable whenNotPaused {
        require(msg.value > 0, "Amount must be greater than 0");
        emit DepositedETH(msg.sender, msg.value);
    }

    function depositETH() external payable whenNotPaused {
        require(msg.value > 0, "Amount must be greater than 0");
        emit DepositedETH(msg.sender, msg.value);
    }

    /// @notice Direct ETH withdrawal (for emergency or owner-only operations)
    function withdrawETH(address payable to, uint256 amount)
        external
        onlyOwner
        whenNotPaused
        nonReentrant
    {
        require(to != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be greater than 0");
        require(address(this).balance >= amount, "Insufficient ETH balance");
        _processWithdrawal(to, amount);
    }

    // -------- ERC20 Handling --------
    function depositERC20(address token, uint256 amount)
        external
        whenNotPaused
        nonReentrant
    {
        require(token != address(0), "Invalid token address");
        require(amount > 0, "Amount must be greater than 0");
        
        // SafeERC20 handles non-standard tokens (USDT, etc.)
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        emit DepositedERC20(token, msg.sender, amount);
    }

    /// @notice Execute token transfer (DAO interface for ERC20 transfers)
    /// @param to Recipient address
    /// @param token Token contract address
    /// @param amount Amount to transfer
    /// @return withdrawalId Returns 0 for immediate execution (no queuing for ERC20)
    function executeToken(address to, address token, uint256 amount)
        external
        onlyOwner
        whenNotPaused
        nonReentrant
        returns (uint256)
    {
        require(token != address(0), "Invalid token address");
        require(to != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be greater than 0");
        require(IERC20(token).balanceOf(address(this)) >= amount, "Insufficient token balance");
        
        IERC20(token).safeTransfer(to, amount);
        emit WithdrawnERC20(token, to, amount);
        return 0; // No withdrawal ID for immediate ERC20 transfers
    }

    /// @notice Direct ERC20 withdrawal (for emergency or owner-only operations)
    function withdrawERC20(address token, address to, uint256 amount)
        external
        onlyOwner
        whenNotPaused
        nonReentrant
    {
        require(token != address(0), "Invalid token address");
        require(to != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be greater than 0");
        require(IERC20(token).balanceOf(address(this)) >= amount, "Insufficient token balance");
        
        IERC20(token).safeTransfer(to, amount);
        emit WithdrawnERC20(token, to, amount);
    }

    // -------- Timelock Queue (DAO Interface) --------
    /// @notice Queue a withdrawal with timelock - matches DAO interface
    /// @param recipient Address to receive funds
    /// @param amount Amount to withdraw in wei
    /// @return withdrawalId Unique identifier for this withdrawal
    function queueWithdrawal(address recipient, uint256 amount)
        external
        onlyOwner
        whenNotPaused
        returns (uint256)
    {
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be greater than 0");
        require(address(this).balance >= amount, "Insufficient balance");

        uint256 withdrawalId = ++withdrawalCount;
        uint256 unlockTime = block.timestamp + withdrawalDelay;

        queuedWithdrawals[withdrawalId] = QueuedWithdrawal({
            recipient: recipient,
            amount: amount,
            unlockTime: unlockTime,
            executed: false,
            cancelled: false
        });

        emit WithdrawalQueued(withdrawalId, recipient, amount, unlockTime);
        return withdrawalId;
    }

    /// @notice Execute a queued withdrawal - matches DAO interface
    /// @param withdrawalId The ID of the withdrawal to execute
    function executeWithdrawal(uint256 withdrawalId)
        external
        onlyOwner
        whenNotPaused
        nonReentrant
    {
        QueuedWithdrawal storage withdrawal = queuedWithdrawals[withdrawalId];
        
        require(withdrawal.unlockTime > 0, "Withdrawal does not exist");
        require(!withdrawal.executed, "Already executed");
        require(!withdrawal.cancelled, "Withdrawal cancelled");
        require(block.timestamp >= withdrawal.unlockTime, "Not unlocked yet");
        require(address(this).balance >= withdrawal.amount, "Insufficient balance");

        withdrawal.executed = true;

        _processWithdrawal(payable(withdrawal.recipient), withdrawal.amount);
        emit WithdrawalExecuted(withdrawalId, withdrawal.recipient, withdrawal.amount);
    }

    /// @notice Cancel a queued withdrawal before execution
    /// @param withdrawalId The ID of the withdrawal to cancel
    function cancelWithdrawal(uint256 withdrawalId)
        external
        onlyOwner
    {
        QueuedWithdrawal storage withdrawal = queuedWithdrawals[withdrawalId];
        
        require(withdrawal.unlockTime > 0, "Withdrawal does not exist");
        require(!withdrawal.executed, "Already executed");
        require(!withdrawal.cancelled, "Already cancelled");

        withdrawal.cancelled = true;
        emit WithdrawalCancelled(withdrawalId);
    }

    // -------- Internal --------
    function _processWithdrawal(address payable to, uint256 amount) internal {
        (bool sent, ) = to.call{value: amount}("");
        require(sent, "ETH transfer failed");
        emit WithdrawnETH(to, amount);
    }

    // -------- Admin --------
    /// @notice Update the withdrawal delay with validation
    /// @param delay New delay in seconds
    function setWithdrawalDelay(uint256 delay) external onlyOwner {
        require(delay >= MIN_WITHDRAWAL_DELAY && delay <= MAX_WITHDRAWAL_DELAY, "Invalid delay");
        emit WithdrawalDelayUpdated(withdrawalDelay, delay);
        withdrawalDelay = delay;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // -------- Emergency Functions --------
    /// @notice Emergency ETH withdrawal bypassing normal controls
    /// @dev Only for critical situations, requires owner
    function emergencyWithdraw(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be greater than 0");
        require(address(this).balance >= amount, "Insufficient balance");
        
        (bool sent, ) = to.call{value: amount}("");
        require(sent, "ETH transfer failed");
        
        emit WithdrawnETH(to, amount);
    }

    /// @notice Emergency ERC20 withdrawal bypassing normal controls  
    /// @dev Only for critical situations, requires owner
    function emergencyWithdrawToken(address token, address to, uint256 amount) external onlyOwner {
        require(token != address(0), "Invalid token");
        require(to != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be greater than 0");
        
        IERC20(token).safeTransfer(to, amount);
        emit WithdrawnERC20(token, to, amount);
    }

    // -------- View Functions --------
    function balance() external view returns (uint256) {
        return address(this).balance;
    }

    function balanceETH() external view returns (uint256) {
        return address(this).balance;
    }

    function tokenBalance(address token) external view returns (uint256) {
        require(token != address(0), "Invalid token address");
        return IERC20(token).balanceOf(address(this));
    }

    function balanceERC20(address token) external view returns (uint256) {
        require(token != address(0), "Invalid token address");
        return IERC20(token).balanceOf(address(this));
    }

    /// @notice Get withdrawal details - Updated to match ABI
    function pendingWithdrawals(uint256 withdrawalId) external view returns (
        uint256 id,
        address to,
        uint256 amount,
        uint256 queuedAt,
        bool executed
    ) {
        QueuedWithdrawal storage withdrawal = queuedWithdrawals[withdrawalId];
        return (
            withdrawalId,
            withdrawal.recipient,
            withdrawal.amount,
            withdrawal.unlockTime,
            withdrawal.executed
        );
    }

    /// @notice Get withdrawal details
    function getWithdrawal(uint256 withdrawalId) external view returns (
        address recipient,
        uint256 amount,
        uint256 unlockTime,
        bool executed,
        bool cancelled
    ) {
        QueuedWithdrawal storage withdrawal = queuedWithdrawals[withdrawalId];
        return (
            withdrawal.recipient,
            withdrawal.amount,
            withdrawal.unlockTime,
            withdrawal.executed,
            withdrawal.cancelled
        );
    }

    /// @notice Check if withdrawal is ready to execute
    function isWithdrawalReady(uint256 withdrawalId) external view returns (bool) {
        QueuedWithdrawal storage withdrawal = queuedWithdrawals[withdrawalId];
        return withdrawal.unlockTime > 0 
            && !withdrawal.executed 
            && !withdrawal.cancelled 
            && block.timestamp >= withdrawal.unlockTime;
    }

    /// @notice Get all pending withdrawal IDs
    function getPendingWithdrawals() external view returns (uint256[] memory) {
        uint256 count;
        for (uint256 i = 1; i <= withdrawalCount; i++) {
            QueuedWithdrawal storage withdrawal = queuedWithdrawals[i];
            if (!withdrawal.executed && !withdrawal.cancelled) {
                count++;
            }
        }

        uint256[] memory result = new uint256[](count);
        uint256 idx;
        for (uint256 i = 1; i <= withdrawalCount; i++) {
            QueuedWithdrawal storage withdrawal = queuedWithdrawals[i];
            if (!withdrawal.executed && !withdrawal.cancelled) {
                result[idx++] = i;
            }
        }
        return result;
    }
}
