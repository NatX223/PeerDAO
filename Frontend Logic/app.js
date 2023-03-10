// Importing the Ethers.js
const { ethers } = require(ethers);
// importing contracts ABI
import { DAOcontractabi } from "./DAOContractABI.js";
import { tokencontractabi } from "./tokenContractABI.js";

var signer; // ethers.js object for calling functions
var address; // the address of the user

const DAOContractAddress = "0xc9f770f25449064183847aCD7138396771faCAa9";
const tokenContractAddress = "0xAbAdA458A67c27CF5F3BFFba00fA0EC76eF6a16F";

const tokenContract = new ethers.Contract(tokenContractAddress, tokencontractabi, signer);
const DAOContract = new ethers.Contract(DAOContractAddress, DAOcontractabi, signer);

// function to connect wallet using the Ethers.js library
async function connectWallet() {
    const provider = new ethers.providers.Web3Provider(window.ethereum);

    await provider.send("eth_requestAccounts", []);

    signer = provider.getSigner();

    address = await signer.getAddress();
}

// function to join DAO
async function enterDAO() {
    const role = "member";
    // The join amount
    const _joinAmount = 50 * (10 * 18);
    const joinAmount = BigInt(_joinAmount);
    // approving the dao contract to get PED tokens from the user
    await tokenContract.approve(DAOContractAddress, joinAmount);
    // calling the main function
    await DAOContract.joinDAO(role);

    // display succes message modal
}

// function to create proposal
// details should be string
// file is a file
async function makeProposal(details, file) {
    // encrypt and upload file to lighthouse and get cid back

    // creating the proposal by calling the smart contract function
    await DAOContract.createProposal(CID, details);

    // display a success modal

}

// function to vote on a proposal
// id is gotten from the proposal struct returned
async function voteProposal(id) {
    // caliing the smart contract function
    await DAOContract.voteContribution(id);

    // display success message
}

// function to gain access to a video by paying a specific amount
// videoId should be int
async function obtainAccess(videoId) {
    // calling the smart contract to grant access
    await DAOContract.getAccess(videoId, { value: ethers.utils.parseUnits("0.1", "ether")} );
}

// function to watch a particular video
// vidCID gotten from the upload 
async function watchVideo(vidId, vidCID) {
    // decrypt video with Lighthouse by calling the accessible function of the smart contract by passing in the videoId as function parameter

}

// function to return all members
async function getMembers() {
    await DAOContract.getAllMembers();

    // get the JSON and handle it (displaying it)
    // structure
    // address
    // role
}

// function to return all proposals
async function getProposals() {
    await DAOContract.getAllProposals();

    // get the JSON and handle it (displaying it)
    // structure
    // id -- to be used when voting for voting on proposals
    // poster -- the address of the owner of the video
    // description -- brief desription of the video
    // contentHash -- the cid/hash of the video, to be decrypted and viewed by DAO members
    // forVotes -- the amount of votes the proposal has
}

// function to return all videos
async function getVideos() {
    await DAOContract.getAllVideos();

    // get the JSON and handle it (displaying it)
    // id -- used to gain access to a video
    // poster -- the address of the owner of the video
    // description -- brief desription of the video
    // contentHash -- the cid/hash of the video, to be decrypted and viewed by DAO members6
}

// function to purchase PED tokens
// _amount should be of type int
async function getPEDtokens(_amount) {
   const amount = _amount * (10 ** 18);
   const purchaseAmount = BigInt(amount);

   await tokenContract.buyToken({value: purchaseAmount});

   // display success message
}
