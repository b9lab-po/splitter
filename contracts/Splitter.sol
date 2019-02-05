pragma solidity ^0.4.24;

contract Splitter {
    address public owner;
    address public firstPerson;
    address public secondPerson;

    mapping(address => uint) public balances;

    event LogOwner(address indexed owner);
    event LogSplit(address owner, address firstPerson, address secondPerson, uint amount);
    event LogWithdraw(address person, uint amount);

    constructor (address firstPerson, address secondPerson) public {
        require(firstPerson != address(0), "The address is not set");
        require(secondPerson != address(0), "The address is not set");
        owner = msg.sender;
        emit LogOwner(owner);

        this.firstPerson = firstPerson;
        this.secondPerson = secondPerson;
    }

    function split() public payable {
        require(msg.sender == owner, "You are not the owner!");
        require(msg.value > 0, "The amount is too low!");

        uint256 halfAmount = msg.value / 2;

        balances[owner] += msg.value % 2 == 0 ? 0 : 1;
        balances[firstPerson] += halfAmount;
        balances[secondPerson] += halfAmount;

        emit LogSplit(msg.sender, firstPerson, secondPerson, halfAmount);
    }

    function withdraw() public {
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        emit LogWithdraw(msg.sender, amount);
        msg.sender.transfer(amount);
    }
}

