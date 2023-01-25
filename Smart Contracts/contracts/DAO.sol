// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";

// INTERFACES

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address from, address to, uint amount) external;

}

contract PeerDAO {

    using Counters for Counters.Counter; // OpenZepplin Counter
    Counters.Counter private _proposalCount; // Counter For Posts

    // VARIABLES
    IERC20 peerToken;
    uint joinAmount;
    uint contributionAmount;
    uint successThreshold;

    // DATA STRUCTURES

    mapping (address => string) profile;
    mapping (address => bool) members;
    mapping (uint => Proposal) Proposals;
    mapping (uint => uint) conPropCount;
    mapping (uint => bool) exists;
    mapping (uint => proposalCore) state;
    
    // implement proposal core struct with
    struct proposalCore {
        uint startTime;
        uint deadline;
        bool executed;
        bool failed;
        bool succeded;
    }

    enum proposalState {active, executed, failed, succeded}

    // proposal struct
    struct Proposal {
        address proposer;
        string description;
        string contentHash;
        uint forVotes;
        mapping (address => bool) voters;
    }

    // struct of a member
    struct Member {
        address memberAddress;
        string role;
    }

    // the array of all DAO members
    Member[] allMembers;

    // EVENTS
    
    event joinsDAO(address account, uint timestamp);
    event proposalCreated(address proposer, string content);

    constructor(address _tokenAddress, uint _joinAmount, uint _contributionAmount) {

        // INITIALIZATIONS
        peerToken = IERC20(_tokenAddress);
        joinAmount = _joinAmount;
        contributionAmount = _contributionAmount;
        
    }

    // MODIFIERS

    // modifier to ensure that the user has enough tokens to join the DAO
    modifier hasTokens() {
        require(peerToken.balanceOf(msg.sender) >= joinAmount);
        _;
    }

    // modifier to ensure that the user has enough tokens to make a proposal
    modifier hasContributionTokens() {
        uint balance = peerToken.balanceOf(msg.sender);
        require(balance >= contributionAmount);
        _;
    }

    // modifier to ensure that the user has enough tokens to make a proposal
    modifier hasNotVoted(uint proposalId) {
        bool voted = Proposals[proposalId].voters[msg.sender];
        require(voted != true);
        _;
    }

    // modifier to ensure that the user has enough tokens to make a proposal
    modifier isStillActive(uint proposalId) {
        require(getState(proposalId) == proposalState.active);
        _;
    }

    // modifier to ensure that the user has enough tokens to make a proposal
    modifier proposalExists(uint proposalId) {
        require(exists[proposalId] == true);
        _;
    }

    // modifier to allow only DAO members to vote
    modifier isMemeber() {
        require(members[msg.sender] == true);
        _;
    }

    // PUBLIC FUNCTIONS

    // function for a member to join the DAO
    function joinDAO (string memory _role) public hasTokens {
        peerToken.transferFrom(msg.sender, address(this), joinAmount);
        members[msg.sender] = true;

        Member member;

        member = Member(msg.sender, _role);
        allMembers.push(member);

        emit joinsDAO(msg.sender, block.timestamp);
    }

    // function to create contribution proposal
    function createProposal(string memory _contentHash, string memory details) public hasContributionTokens {
        peerToken.transferFrom(msg.sender, address(this), contributionAmount);
        
        _proposalCount.increment();
        uint256 proposalCount = _proposalCount.current(); 
        Proposals[proposalCount].contentHash = _contentHash;
        Proposals[proposalCount].description = details;
        Proposals[proposalCount].forVotes = 0;
        Proposals[proposalCount].proposer = msg.sender;

        state[proposalCount].startTime = block.timestamp;
        state[proposalCount].deadline = block.timestamp + 2 weeks;
        state[proposalCount].executed = false;
        state[proposalCount].failed = false;

        exists[proposalCount] = true;
        
        emit proposalCreated(msg.sender, _contentHash);
    }

    // function for user to cast vote for a contribution proposal
    function voteContribution(uint proposalId) public hasNotVoted(proposalId) isStillActive(proposalId) proposalExists(proposalId) isMemeber {
        Proposals[proposalId].voters[msg.sender] = true;
        Proposals[proposalId].forVotes = Proposals[proposalId].forVotes + 1;

        // update the forvotes for every vote
        // check if the votes are enough 
        // if they are execute automatically
        // check and fail automatically 
        
    }

    // function to get the state of a proposal
    function getState(uint proposalId) public view returns(proposalState) {

        if (state[proposalId].deadline > block.timestamp) {
            return proposalState.active;
        }

        if (state[proposalId].executed) {
            return proposalState.executed;
        }
        
        if (state[proposalId].succeded) {
            return proposalState.succeded;
        }

        if (state[proposalId].failed) {
            return proposalState.failed;
        }
    }

}

