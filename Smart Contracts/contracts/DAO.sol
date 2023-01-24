// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// INTERFACES

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address from, address to, uint amount) external;

}

contract PeerDAO {

    // VARIABLES
    IERC20 peerToken;
    uint joinAmount;
    uint contributionAmount;
    // use counter library instead
    uint proposalCount;
    uint successThreshold;

    // DATA STRUCTURES

    mapping (address => string) profile;
    mapping (address => bool) members;
    mapping (uint => Proposal) Proposals;
    mapping (uint => uint) conPropCount;
    mapping (uint => bool) exists;
    
    // implement proposal core struct with
    // start time
    // end time
    // success
    // executed
    // failed

    // implement automatic executed of proposals if proposal reaches theshhold

    // proposal struct
    struct Proposal {
        address proposer;
        string description;
        string contentHash;
        uint forVotes;
        bool pending;
        uint createionTime;
        bool executed;
        bool failed;
        mapping (address => bool) voters;
    }


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
        require(Proposals[proposalId].pending == true);
        _;
    }

    // modifier to ensure that the user has enough tokens to make a proposal
    modifier ideaExists(uint proposalId) {
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
    function joinDAO (string memory _profile) public hasTokens {
        peerToken.transferFrom(msg.sender, address(this), joinAmount);
        members[msg.sender] = true;
        profile[msg.sender] = _profile;

        emit joinsDAO(msg.sender, block.timestamp);
    }

    // function to create contribution proposal
    function createIdeaProposal(string memory _contentHash, string memory details) public {
        peerToken.transferFrom(msg.sender, address(this), contributionAmount);
        proposalCount = proposalCount + 1;

        Proposals[proposalCount].createionTime = block.timestamp;
        Proposals[proposalCount].contentHash = _contentHash;
        Proposals[proposalCount].description = details;
        Proposals[proposalCount].forVotes = 0;
        Proposals[proposalCount].pending = true;
        Proposals[proposalCount].proposer = msg.sender;

        exists[proposalCount] = true;
        
        emit proposalCreated(msg.sender, _contentHash);
    }

    // function for user to cast vote for a contribution proposal
    function voteContribution(uint proposalId) public hasNotVoted(proposalId) isStillActive(proposalId) ideaExists(proposalId) isMemeber {
        Proposals[proposalId].voters[msg.sender] = true;
        Proposals[proposalId].forVotes = Proposals[proposalId].forVotes + 1;
        
    }

}

