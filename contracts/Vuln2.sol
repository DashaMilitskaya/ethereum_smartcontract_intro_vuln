// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8;


//import "hardhat/console.sol";


contract Vuln2 {

    address private owner;

    mapping (address => uint) private balances;
    
    constructor () payable {

        owner = msg.sender;

        if (msg.value > 0) {
            deposit();
        }
    }

    modifier OnlyOwner () {
        require(msg.sender == owner, "OnlyOwner");
        _;
    }

    function balanceOf (address addr) public view returns (uint){
        return balances[addr];
    }

    function deposit () public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw (uint amount) public {

        require (amount > 0, "amount is null");
        require (balances[msg.sender] >= amount, "amount too big");

        msg.sender.call{value: amount} ("");

        unchecked {
            balances[msg.sender] -= amount;
        }
    }


}
