// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8;


//import "hardhat/console.sol";


contract Vuln3Executor {

    address private owner;

    mapping (address => uint) private balances;

    uint private errorAmount;

    event DepositEvent (address, uint);
    event WithdrawEvent (address, uint);

    constructor () {
        
    }

    modifier OnlyOwner () {
        require(msg.sender == owner, "OnlyOwner");
        _;
    }

    function balanceOf (address addr) public view returns (uint){
        //console.log ("balanceOf %s %s %d\n", msg.sender, addr, balances[addr]);
        return balances[addr];
    }

    function deposit (uint amount) public payable {

        balances[msg.sender] += msg.value;
        if (amount > msg.value) {
            unchecked {
                errorAmount += amount - msg.value;
            }
        }

        emit DepositEvent (msg.sender, msg.value);
        //console.log ("deposit %s %d %d\n", msg.sender, msg.value, amount);
    }

    function withdraw (uint amount) public {

        require (amount > 0, "amount is null");
        require (balances[msg.sender] >= amount, "amount too big");
        balances[msg.sender] -= amount;

        msg.sender.call{value: amount} ("");

        emit WithdrawEvent (msg.sender, amount);
        //console.log ("withdraw %s %d %d\n", msg.sender, amount, balances[msg.sender]);
    }
    
}


contract Vuln3 {

    address private owner;

    mapping (address => uint) private balances;

    Vuln3Executor private executor;
    
    constructor () payable {

        executor = new Vuln3Executor();

        owner = msg.sender;

        if (msg.value > 0) {
            deposit (msg.value);
        }
    }

    function balanceOf (address addr) public returns (uint){
        (, bytes memory res) = address(executor).delegatecall(abi.encodeWithSignature("balanceOf(address)", addr));
        
        return uint(bytes32(res));
    }

    function deposit (uint amount) public payable {
        (bool ret,) = address(executor).delegatecall(abi.encodeWithSignature("deposit(uint256)", amount));
        require (ret == true, "Error deposit");
    }

    function withdraw (uint amount) public {
        (bool ret,) = address(executor).delegatecall(abi.encodeWithSignature("withdraw(uint256)", amount));
        require (ret == true, "Error withdraw");
    }

    function GetExecutor () public view returns (address) {
        return address(executor);
    }

}
