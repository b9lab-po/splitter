pragma solidity ^0.4.24;

contract Splitter {
    address public owner;

    struct People {
        address person;
        uint256 balance;
    }

    People[2] public people;
    
    event LogOwner(address indexed owner);
    event LogSplit(address person, uint amount);
    event LogWithdraw(address person, uint amount);
    
    constructor (address firstPerson, address secondPerson) public {
        owner = msg.sender;
        emit LogOwner(owner);

        people[0].person = firstPerson;
        people[0].balance = 0;
        people[1].person = secondPerson;
        people[1].balance = 0;
    }

    modifier validateOwner() {
        require(msg.sender == owner, "You are not the owner!");
        _;
    }
    
    modifier validateAmount () {
        require(msg.value > 0, "The amount is too low!");
        _;
    }

    function split() public payable validateOwner validateAmount {
        require(people[0].person != address(0), "The address is not set");
        require(people[1].person != address(0), "The address is not set");
        
        uint256 halfAmount = (msg.value - (msg.value % 2)) / 2;

        for(uint i = 0; i < 2; i++) {
            people[i].balance += halfAmount;
        }

        emit LogSplit(people[0].person, halfAmount);
        emit LogSplit(people[1].person, halfAmount);
    }
    
    function withdraw() public {
        for (uint i=0; i<2; i++) {
            if (msg.sender == people[i].person && people[i].balance > 0) {
                uint amount = people[i].balance;
                people[i].balance = 0;
                people[i].person.transfer(amount);
                emit LogWithdraw(people[i].person, amount);
            }
        }
    }
}

