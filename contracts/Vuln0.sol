// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8;


//import "hardhat/console.sol";


// Пример уязвимого контракта.
contract Vuln0 {

    constructor () payable {

    }

    function withdraw (uint a) public {

        require (a == 31337, "Not owner");

        payable(msg.sender).transfer (address(this).balance);
    }

}
