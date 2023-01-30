// Importing the Ethers.js
const { ethers } = require(ethers);
// importing contracts ABI
import { DAOcontractabi } from "./tokenContractABI.js";
import { DAOtokencontractabi } from "./tokenContractABI.js";

var signer; // ethers.js object for calling functions
var address; // the address of the user

// function to connect wallet using the Ethers.js library
async function connectWallet() {
    const provider = new ethers.providers.Web3Provider(window.ethereum);

    await provider.send("eth_requestAccounts", []);

    signer = provider.getSigner();

    address = await signer.getAddress();
}


