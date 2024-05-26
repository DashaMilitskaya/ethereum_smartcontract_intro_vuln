// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8;


import "./Vuln0.sol";
import "./Vuln1.sol";
import "./Vuln2.sol";
import "./Vuln3.sol";
import "./Vuln4.sol";


uint constant MIN_CONSTRUCTOR_VALUE = 1000;

contract VulnFactory {

    address private owner;

    enum VulnTypes {Vuln0, Vuln1, Vuln2, Vuln3, Vuln4}

    event DeployVuln0Event (address);
    event DeployVuln1Event (address);
    event DeployVuln2Event (address);
    event DeployVuln3Event (address);
    event DeployVuln4Event (address);

    mapping (address => VulnTypes) private types;


    constructor () payable {

        owner = msg.sender;

    }

    modifier NeedAmount() {
        require (msg.value >= MIN_CONSTRUCTOR_VALUE, "Need amount");
        _;
    }

    function DeployVuln0 () public payable NeedAmount returns (address retAddr) {

        Vuln0 v = (new Vuln0){value: msg.value} ();

        retAddr = address (v);
        types[retAddr] = VulnTypes.Vuln0;

        emit DeployVuln0Event (retAddr);
    }

    function DeployVuln1 () public payable NeedAmount returns (address retAddr) {

        Vuln1 v = (new Vuln1){value: msg.value} ();

        retAddr = address (v);

        types[retAddr] = VulnTypes.Vuln1;

        emit DeployVuln1Event (retAddr);
    }

    function DeployVuln2 () public payable NeedAmount returns (address retAddr) {

        Vuln2 v = (new Vuln2){value: msg.value} ();

        retAddr = address (v);

        types[retAddr] = VulnTypes.Vuln2;

        emit DeployVuln2Event (retAddr);
    }

    function DeployVuln3 () public payable NeedAmount returns (address retAddr) {

        Vuln3 v = (new Vuln3){value: msg.value} ();

        retAddr = address (v);

        types[retAddr] = VulnTypes.Vuln3;

        emit DeployVuln3Event (retAddr);
    }

    function DeployVuln4 () public payable NeedAmount returns (address retAddr) {

        Vuln4 v = (new Vuln4){value: msg.value} ();

        retAddr = address (v);

        types[retAddr] = VulnTypes.Vuln4;

        emit DeployVuln4Event (retAddr);
    }


}
