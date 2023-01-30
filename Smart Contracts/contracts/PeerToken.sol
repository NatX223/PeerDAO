// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// importing the ERC20 token contract
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract peerToken is ERC20 {
    
    // total supply of the token i.e total amount of tokens that can exist
    uint maxSupply = 10000000 * (10 ** 18);
    address owner;
    uint ownerSupply = 10000 * (10 ** 18);


    constructor(string memory _name, string memory  _symbol) ERC20(_name, _symbol) {
        owner = msg.sender;

        _mint(msg.sender, ownerSupply);
    }

    function buyToken() public payable  {
        require(totalSupply() <= maxSupply, "token supply limit has been reached");
        uint mintAnount = msg.value / 100;

        _mint(msg.sender, mintAnount);

    }

    function mintOwner() public {
        require(msg.sender == owner, "You do not have access to this function");

        _mint(msg.sender, ownerSupply);
    }

}