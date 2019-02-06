pragma solidity ^0.4.24;

contract Splitter {

    mapping(address => uint) public balances;

    event LogOwner(address indexed owner);
    event LogSplit(address owner, address firstPerson, address secondPerson, uint amount);
    event LogWithdraw(address person, uint amount);

    constructor () public {
        emit LogOwner(msg.sender);
    }

    function split(address firstPerson, address secondPerson) public payable {
        require(msg.value > 0, "The amount is too low!");
        require(firstPerson != address(0), "The address is not set");
        require(secondPerson != address(0), "The address is not set");

        uint256 halfAmount = msg.value / 2;

        uint remainder = msg.value % 2;
        if(remainder > 0) {
            balances[msg.sender] += remainder;
        }
        balances[firstPerson] += halfAmount;
        balances[secondPerson] += halfAmount;

        emit LogSplit(msg.sender, firstPerson, secondPerson, halfAmount);
    }

    function withdraw() public {
        uint amount = balances[msg.sender];
        require(amount > 0, "There is nothing to withdraw!");
        balances[msg.sender] = 0;
        emit LogWithdraw(msg.sender, amount);
        msg.sender.transfer(amount);
    }
}

