// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice DAO contract with safe proposal/vote/fund execution flow.
/// @dev Requires a GovernanceToken implementing ERC20Votes (getPastVotes) and a Treasury with owner = DAO.
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

interface IGovernanceToken {
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function getPastVotes(address account, uint256 timepoint) external view returns (uint256);
    function getPastTotalSupply(uint256 timepoint) external view returns (uint256);
}

interface ITreasury {
    function owner() external view returns (address);
    function queueWithdrawal(address recipient, uint256 amount) external returns (uint256);
    function executeWithdrawal(uint256 withdrawalId) external;
}

contract DAO is Ownable, ReentrancyGuard, Pausable {
    IGovernanceToken public govToken;
    ITreasury public treasury;
    uint256 public proposalCount;

    enum ProposalState { Active, Passed, Rejected, Executed, Cancelled }

    // Split into two structs to avoid stack too deep
    struct ProposalCore {
        uint256 id;
        address proposer;
        string title;
        string descriptionCID;
        uint256 snapshotBlock;
        uint256 startTime;
        uint256 endTime;
        ProposalState state;
    }

    struct ProposalExecution {
        bool executed;
        address target;
        uint256 value;
        uint256 timelockEnd;
        uint256 treasuryWithdrawalId;
    }

    struct ProposalVotes {
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 votesAbstain;
    }

    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(uint256 => ProposalCore) public proposalCore;
    mapping(uint256 => ProposalExecution) public proposalExecution;
    mapping(uint256 => ProposalVotes) public proposalVotes;
    mapping(address => bool) public allowedTargets;

    event ProposalCreated(uint256 indexed id, address indexed proposer, string title, uint256 startTime, uint256 endTime);
    event Voted(uint256 indexed id, address indexed voter, uint8 choice, uint256 weight);
    event ProposalFinalized(uint256 indexed id, ProposalState state);
    event ProposalExecuted(uint256 indexed id, address indexed executor);
    event ProposalCancelled(uint256 indexed id, address indexed cancelledBy);
    event AllowedTargetUpdated(address indexed target, bool allowed);
    event VotingPeriodUpdated(uint256 oldPeriod, uint256 newPeriod);
    event QuorumPercentUpdated(uint256 oldPct, uint256 newPct);
    event ExecutionDelayUpdated(uint256 oldDelay, uint256 newDelay);
    event ProposalThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);
    event TreasuryLinked(address indexed newTreasury);

    uint256 public votingPeriod = 3 days;
    uint256 public quorumPercent = 10; // 10% quorum
    uint256 public executionDelay = 1 days;
    uint256 public proposalThreshold = 1e18; // 1 token minimum
    
    // Security constants
    uint256 public constant MAX_VOTING_PERIOD = 30 days;
    uint256 public constant MIN_VOTING_PERIOD = 1 hours;
    uint256 public constant MAX_QUORUM_PERCENT = 50; // Max 50% to prevent impossibility
    uint256 public constant MIN_QUORUM_PERCENT = 1; // Min 1% to prevent spam
    uint256 public constant MAX_EXECUTION_DELAY = 30 days;
    uint256 public constant MIN_EXECUTION_DELAY = 1 hours;

    modifier onlyActiveProposal(uint256 proposalId) {
        require(proposalCore[proposalId].state == ProposalState.Active, "Proposal not active");
        _;
    }

    constructor(address _govToken, address _treasury, address initialOwner) Ownable(initialOwner) {
        require(_govToken != address(0), "Invalid token address");
        require(initialOwner != address(0), "Invalid owner address");
        
        govToken = IGovernanceToken(_govToken);
        
        // Allow treasury to be address(0) initially - it can be linked later
        if (_treasury != address(0)) {
            treasury = ITreasury(_treasury);
        }
    }
    function linkTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0), "Invalid treasury address");
        treasury = ITreasury(_treasury);
        emit TreasuryLinked(_treasury);
    }

    function createProposal(
        string memory title,
        string memory descriptionCID,
        address target,
        uint256 value
    ) external whenNotPaused returns (uint256) {
        require(bytes(title).length > 0, "Title required");
        require(bytes(title).length <= 200, "Title too long"); // Prevent spam
        require(bytes(descriptionCID).length > 0, "Description CID required");
        require(bytes(descriptionCID).length <= 100, "CID too long"); // Prevent spam
        require(govToken.balanceOf(msg.sender) >= proposalThreshold, "Insufficient tokens to propose");
        require(value <= address(treasury).balance, "Insufficient treasury funds"); // Prevent unrealistic proposals
        
        if (target != address(0)) {
            require(allowedTargets[target], "Target not allowed");
        }
        
        uint256 id = ++proposalCount;
        uint256 snapshotBlock = block.timestamp; // Use timestamp to match token's clock mode
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + votingPeriod;
        
        proposalCore[id] = ProposalCore({
            id: id,
            proposer: msg.sender,
            title: title,
            descriptionCID: descriptionCID,
            snapshotBlock: snapshotBlock,
            startTime: startTime,
            endTime: endTime,
            state: ProposalState.Active
        });
        
        proposalExecution[id] = ProposalExecution({
            executed: false,
            target: target,
            value: value,
            timelockEnd: 0,
            treasuryWithdrawalId: 0
        });
        
        emit ProposalCreated(id, msg.sender, title, startTime, endTime);
        return id;
    }

    function vote(uint256 proposalId, uint8 choice) external onlyActiveProposal(proposalId) whenNotPaused nonReentrant {
        require(choice <= 2, "Invalid choice"); // 0=For, 1=Against, 2=Abstain
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        require(block.timestamp >= proposalCore[proposalId].startTime, "Voting not started");
        require(block.timestamp <= proposalCore[proposalId].endTime, "Voting ended");
        
        uint256 weight = govToken.getPastVotes(msg.sender, proposalCore[proposalId].snapshotBlock);
        require(weight > 0, "No voting power");
        
        // Update state BEFORE emitting events to prevent reentrancy
        hasVoted[proposalId][msg.sender] = true;
        
        if (choice == 0) {
            proposalVotes[proposalId].votesFor += weight;
        } else if (choice == 1) {
            proposalVotes[proposalId].votesAgainst += weight;
        } else {
            proposalVotes[proposalId].votesAbstain += weight;
        }
        
        emit Voted(proposalId, msg.sender, choice, weight);
    }

    function finalizeProposal(uint256 proposalId) external onlyActiveProposal(proposalId) {
        require(block.timestamp > proposalCore[proposalId].endTime, "Voting still active");
        
        bool quorumReached = _quorumReached(proposalId);
        bool majorityFor = proposalVotes[proposalId].votesFor > proposalVotes[proposalId].votesAgainst;
        
        if (quorumReached && majorityFor) {
            proposalCore[proposalId].state = ProposalState.Passed;
            
            // If this involves treasury withdrawal, prepare timelock
            if (proposalExecution[proposalId].target != address(0) && proposalExecution[proposalId].value > 0) {
                proposalExecution[proposalId].timelockEnd = block.timestamp + executionDelay;
            }
        } else {
            proposalCore[proposalId].state = ProposalState.Rejected;
        }
        
        emit ProposalFinalized(proposalId, proposalCore[proposalId].state);
    }
    function executeProposal(uint256 proposalId) external nonReentrant {
        require(proposalCore[proposalId].state == ProposalState.Passed, "Not passed");
        require(!proposalExecution[proposalId].executed, "Already executed");
        
        // Check timelock if this involves treasury withdrawal
        if (proposalExecution[proposalId].value > 0) {
            require(block.timestamp >= proposalExecution[proposalId].timelockEnd, "Timelock not expired");
            require(address(treasury) != address(0), "Treasury not linked");
            
            // Queue withdrawal from treasury
            uint256 withdrawalId = treasury.queueWithdrawal(
                proposalExecution[proposalId].target,
                proposalExecution[proposalId].value
            );
            proposalExecution[proposalId].treasuryWithdrawalId = withdrawalId;
        }
        
        proposalExecution[proposalId].executed = true;
        proposalCore[proposalId].state = ProposalState.Executed;
        
        emit ProposalExecuted(proposalId, msg.sender);
    }

    function executeTreasuryWithdrawal(uint256 proposalId) external {
        require(proposalCore[proposalId].state == ProposalState.Executed, "Proposal not executed");
        require(proposalExecution[proposalId].treasuryWithdrawalId > 0, "No withdrawal to execute");
        require(address(treasury) != address(0), "Treasury not linked");
        
        treasury.executeWithdrawal(proposalExecution[proposalId].treasuryWithdrawalId);
    }

    function cancelProposal(uint256 proposalId) external {
        require(
            msg.sender == proposalCore[proposalId].proposer || msg.sender == owner(),
            "Only proposer or owner can cancel"
        );
        require(proposalCore[proposalId].state == ProposalState.Active, "Cannot cancel");
        
        proposalCore[proposalId].state = ProposalState.Cancelled;
        emit ProposalCancelled(proposalId, msg.sender);
    }

    // View functions
    function _quorumReached(uint256 proposalId) internal view returns (bool) {
        uint256 totalVotes = proposalVotes[proposalId].votesFor + 
                           proposalVotes[proposalId].votesAgainst + 
                           proposalVotes[proposalId].votesAbstain;
        uint256 totalSupply = govToken.getPastTotalSupply(proposalCore[proposalId].snapshotBlock);
        
        if (totalSupply == 0) return false;
        
        // Use safe math to prevent overflow: (totalVotes * 100) / totalSupply >= quorumPercent
        // Rearranged to: totalVotes >= (totalSupply * quorumPercent) / 100
        uint256 requiredVotes = (totalSupply * quorumPercent) / 100;
        return totalVotes >= requiredVotes;
    }

    function getProposal(uint256 proposalId) external view returns (
        uint256 id,
        address proposer,
        string memory title,
        string memory descriptionCID,
        uint256 snapshotBlock,
        uint256 startTime,
        uint256 endTime,
        ProposalState state,
        uint256 votesFor,
        uint256 votesAgainst,
        uint256 votesAbstain,
        bool executed,
        address target,
        uint256 value
    ) {
        ProposalCore memory core = proposalCore[proposalId];
        ProposalVotes memory votes = proposalVotes[proposalId];
        ProposalExecution memory exec = proposalExecution[proposalId];
        
        return (
            core.id,
            core.proposer,
            core.title,
            core.descriptionCID,
            core.snapshotBlock,
            core.startTime,
            core.endTime,
            core.state,
            votes.votesFor,
            votes.votesAgainst,
            votes.votesAbstain,
            exec.executed,
            exec.target,
            exec.value
        );
    }

    function getActiveProposals() external view returns (uint256[] memory) {
        uint256[] memory temp = new uint256[](proposalCount);
        uint256 count = 0;
        
        for (uint256 i = 1; i <= proposalCount; i++) {
            if (proposalCore[i].state == ProposalState.Active) {
                temp[count] = i;
                count++;
            }
        }
        
        uint256[] memory activeProposals = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            activeProposals[i] = temp[i];
        }
        
        return activeProposals;
    }

    // Owner-only functions
    function setVotingPeriod(uint256 _votingPeriod) external onlyOwner {
        require(_votingPeriod >= MIN_VOTING_PERIOD && _votingPeriod <= MAX_VOTING_PERIOD, "Invalid period");
        emit VotingPeriodUpdated(votingPeriod, _votingPeriod);
        votingPeriod = _votingPeriod;
    }

    function setQuorumPercent(uint256 _quorumPercent) external onlyOwner {
        require(_quorumPercent >= MIN_QUORUM_PERCENT && _quorumPercent <= MAX_QUORUM_PERCENT, "Invalid quorum");
        emit QuorumPercentUpdated(quorumPercent, _quorumPercent);
        quorumPercent = _quorumPercent;
    }

    function setExecutionDelay(uint256 _executionDelay) external onlyOwner {
        require(_executionDelay >= MIN_EXECUTION_DELAY && _executionDelay <= MAX_EXECUTION_DELAY, "Invalid delay");
        emit ExecutionDelayUpdated(executionDelay, _executionDelay);
        executionDelay = _executionDelay;
    }

    function setProposalThreshold(uint256 _proposalThreshold) external onlyOwner {
        require(_proposalThreshold <= govToken.totalSupply() / 10, "Threshold too high"); // Max 10% of supply
        emit ProposalThresholdUpdated(proposalThreshold, _proposalThreshold);
        proposalThreshold = _proposalThreshold;
    }

    function setAllowedTarget(address target, bool allowed) external onlyOwner {
        allowedTargets[target] = allowed;
        emit AllowedTargetUpdated(target, allowed);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
