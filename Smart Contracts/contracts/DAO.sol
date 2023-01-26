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
    mapping (uint => mapping (address => bool)) voted;
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
        uint id;
        address proposer;
        string description;
        string contentHash;
        uint forVotes;
    }

    // struct of a member
    struct Member {
        address memberAddress;
        string role;
    }

    // struct of an approved
    struct Video {
        address poster;
        string description;
        string contentHash;
    }

    // the array of all DAO members
    Member[] allMembers;

    // array of the all the proposals
    Proposal[] allProposals;

    // the array of all videos that have been approved
    Video[] allVideos;

    address admin;

    // EVENTS
    
    event joinsDAO(address account, uint timestamp);
    event proposalCreated(address proposer, string content);

    constructor(address _tokenAddress, uint _joinAmount, uint _contributionAmount, uint _successThreshold) {

        // INITIALIZATIONS
        peerToken = IERC20(_tokenAddress);
        joinAmount = _joinAmount;
        contributionAmount = _contributionAmount;
        successThreshold = _successThreshold;
        admin = msg.sender;
        
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
        bool _voted = voted[proposalId][msg.sender];
        require(_voted != true);
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
    modifier _isMember() {
        require(members[msg.sender] == true);
        _;
    }

    // PUBLIC FUNCTIONS

    // function for a member to join the DAO
    function joinDAO (string memory _role) public hasTokens {
        peerToken.transferFrom(msg.sender, address(this), joinAmount);
        members[msg.sender] = true;

        Member memory member;

        member = Member(msg.sender, _role);
        allMembers.push(member);

        emit joinsDAO(msg.sender, block.timestamp);
    }

    // function to create contribution proposal
    function createProposal(string memory _contentHash, string memory details) public hasContributionTokens {
        peerToken.transferFrom(msg.sender, address(this), contributionAmount);
        
        _proposalCount.increment();
        uint256 proposalCount = _proposalCount.current();

        Proposals[proposalCount].id = proposalCount;
        Proposals[proposalCount].contentHash = _contentHash;
        Proposals[proposalCount].description = details;
        Proposals[proposalCount].forVotes = 0;
        Proposals[proposalCount].proposer = msg.sender;

        state[proposalCount].startTime = block.timestamp;
        state[proposalCount].deadline = block.timestamp + 2 weeks;
        state[proposalCount].executed = false;
        state[proposalCount].failed = false;

        exists[proposalCount] = true;

        Proposal memory proposal;
        proposal = Proposals[proposalCount];
        allProposals.push(proposal);

        emit proposalCreated(msg.sender, _contentHash);
    }

    // function for user to cast vote for a contribution proposal
    function voteContribution(uint proposalId) public hasNotVoted(proposalId) isStillActive(proposalId) proposalExists(proposalId) _isMember {
        voted[proposalId][msg.sender] = true;
        Proposals[proposalId].forVotes = Proposals[proposalId].forVotes + 1;

        if (Proposals[proposalId].forVotes >= successThreshold) {
            executeProposal(proposalId);
        }
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

    // function to return all  the members
    function getAllMembers() public view returns(Member[] memory) {
        return allMembers;
    }

    // function to return all the proposals
    function getAllProposals() public view returns(Proposal[] memory) {
        return allProposals;
    }

    // // function to return all videos
    // function getAllvideos() public view returns(Video[] memory) {
        
    // }

    // function to execute a proposal
    function executeProposal (uint proposalId) internal {
        // retreive details
        address poster = Proposals[proposalId].proposer;
        string memory description = Proposals[proposalId].description;
        string memory contentHash = Proposals[proposalId].contentHash;

        // contruct a Video struct
        Video memory video;
        video = Video(poster, description, contentHash);

        // push video to array
        allVideos.push(video);

        // change state of proposal to executed
        state[proposalId].succeded = true;
        state[proposalId].executed = true;
    }

        // function to execute a proposal
    function executeProposalAdmin (uint proposalId) public {
        require(msg.sender == admin, "You are authorized to call this function");
        
        // retreive details
        address poster = Proposals[proposalId].proposer;
        string memory description = Proposals[proposalId].description;
        string memory contentHash = Proposals[proposalId].contentHash;

        // contruct a Video struct
        Video memory video;
        video = Video(poster, description, contentHash);

        // push video to array
        allVideos.push(video);

        // change state of proposal to executed
        state[proposalId].succeded = true;
        state[proposalId].executed = true;
    }

    // function to check if a user is a member of the DAO
    // to be used in access control
    function isMember() public view returns(bool) {
        return members[msg.sender];
    }

}

