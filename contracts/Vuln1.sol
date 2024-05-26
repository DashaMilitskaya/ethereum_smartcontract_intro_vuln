// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8;


//import "hardhat/console.sol";


interface Executor {

    function exec () external returns (uint);

}

contract Vuln1 {

    address payable private owner;

    constructor () payable {

        owner = payable(msg.sender);

    }

    function exec (address impl) public {

        (, bytes memory res) = impl.delegatecall(abi.encodeWithSignature("exec()"));

        require (uint(bytes32(res)) == 0, "Error result of exec");
    }

    function withdraw () public {

        require (msg.sender == owner, "Not owner");
        
        owner.transfer (address(this).balance);
    }

}
