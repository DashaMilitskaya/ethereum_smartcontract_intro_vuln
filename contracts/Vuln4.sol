// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8;


//import "hardhat/console.sol";


contract Vuln4ExecutorBalances {

    mapping (address => int) private balances;

    event DepositEvent (address, uint);
    event WithdrawEvent (address, uint);

    constructor () {
        
    }

    function balanceOf (address addr) public view returns (int){
        //console.log ("balanceOf %s %s %d\n", msg.sender, addr, balances[addr]);
        return balances[addr];
    }

    function deposit () public payable {

        //console.log ("deposit %s %d\n", msg.sender, msg.value);

        balances[msg.sender] += int(msg.value);

        emit DepositEvent (msg.sender, msg.value);
    }

    function withdraw (uint amount) public {

        //console.log ("withdraw %s %d %d\n", msg.sender, amount, uint(balances[msg.sender]));

        require (amount > 0, "amount is null");
        require (balances[msg.sender] > 0, "Null balance");
        require (address(this).balance >= amount, "amount too big");
        
        // Можно взять денег больше чем на балансе,
        balances[msg.sender] -= int(amount);

        (bool status, ) = msg.sender.call{value: amount} ("");
        require (status == true, "Error send");

        // но в конце их надо вернуть
        require (balances[msg.sender] >= 0, "Not returned");

        emit WithdrawEvent (msg.sender, amount);
    }

}


contract Vuln4ExecutorHistory {

    enum HistoryAction {deposit, withdraw}

    struct HistoryRecord {
        HistoryAction action;
        uint amount;
        address addr;
    }
    mapping (address => uint[1]) private history;

    //event PushEvent (address, uint);
    //event GetEvent (address, uint);

    constructor () {
        
    }

    function PushHistory (HistoryAction action, uint amount) public payable {

        uint[1] storage arrRef = history[msg.sender];

        //console.log ("PushHistory start: %s %d %d\n", msg.sender, amount, arrRef[0]);

        uint newEntryIndex = arrRef[0];     // в слоте лежит размер
        unchecked {
            ++arrRef[0];                    // увеличиваем размер на 1
        }

        address sender = msg.sender;

        uint slot;
        uint arrRefSlot;



        assembly {
            arrRefSlot := arrRef.slot

            let offset := mul (newEntryIndex, 3)    // умножаем индекс на размер структуры
            offset := add (offset, 1)               // смещение для первого слота с длиной
            
            slot := add (arrRef.slot, offset)   // слот для структуры
            sstore (slot, action)                   // первый слот структуры - action
            slot := add (slot, 1)
            sstore (slot, amount)                   // второй слот структуры - amount
            slot := add (slot, 1)
            sstore (slot, sender)                   // третий слот структуры - addr
        }

        //console.log ("arrRef.slot = %d   struct slot = %d\n", arrRefSlot, slot);

        //history[msg.sender][newEntryIndex] = HistoryRecord (action, amount, msg.sender);
        //history[msg.sender].push(HistoryRecord (action, amount, msg.sender));

        //emit PushEvent (msg.sender, a);
        //console.log ("PushHistory end: %s %d %d\n", msg.sender, amount, arrRef[0]);
    }

    function GetHistory (uint index) public view returns (HistoryRecord memory ret) {

        uint[1] storage arrRef = history[msg.sender];

        //console.log ("GetHistory: %s %d %d\n", msg.sender, index, arrRef[0]);

        HistoryAction action;
        uint amount;
        address addr;

        require (index < arrRef[0], "index too big");

        assembly {
            let offset := mul (index, 3)
            offset := add (offset, 1)
            
            let slot := add (arrRef.slot, offset)   // слот для структуры
            action := sload (slot)                  // первый слот структуры - action
            slot := add (slot, 1)
            amount := sload (slot)                  // второй слот структуры - amount
            slot := add (slot, 1)
            addr := sload (slot)                    // третий слот структуры - addr
        }

        ret = HistoryRecord (action, amount, addr);

        //emit GetEvent (msg.sender, index);
    }
}


contract Vuln4 {

    address private owner;

    Vuln4ExecutorBalances private executorBalance;
    Vuln4ExecutorHistory private executorHistory;
    
    constructor () payable {

        executorBalance = new Vuln4ExecutorBalances();
        executorHistory = new Vuln4ExecutorHistory();

        owner = msg.sender;

        if (msg.value > 0) {
            deposit ();
        }
    }

    bool globalLock = false;
    modifier MyLock {
        require (globalLock == false, "Error re-entrance");
        globalLock = true;
        _;
        globalLock = false;

    }

    function balanceOf (address addr) public returns (int){
        (, bytes memory res) = address(executorBalance).delegatecall(abi.encodeWithSignature("balanceOf(address)", addr));
        
        return int(uint(bytes32(res)));
    }

    function deposit () public payable {
        (bool status,) = address(executorBalance).delegatecall(abi.encodeWithSignature(
            "deposit()"));
        require (status, "Error deposit");
        
        PushHistory (Vuln4ExecutorHistory.HistoryAction.deposit, msg.value);
    }

    function withdraw (uint amount) public MyLock {
        (bool status,) = address(executorBalance).delegatecall(abi.encodeWithSignature(
            "withdraw(uint256)",
                amount));
        require (status, "Error withdraw");

        PushHistory (Vuln4ExecutorHistory.HistoryAction.withdraw, amount);
    }

    function PushHistory (Vuln4ExecutorHistory.HistoryAction action, uint amount) internal {
        (bool status,) =
            address(executorHistory).delegatecall(abi.encodeWithSignature(
                "PushHistory(uint8,uint256)",
                    action, amount));

        require (status, "Error PushHistory");
    }

    function GetHistory (uint index) public returns (Vuln4ExecutorHistory.HistoryRecord memory) {
        (bool status, bytes memory retBytes) =
            address(executorHistory).delegatecall(abi.encodeWithSignature(
                "GetHistory(uint256)",
                    index));

        require (status, "Error GetHistory");

        return abi.decode (retBytes, (Vuln4ExecutorHistory.HistoryRecord));
    }

}
