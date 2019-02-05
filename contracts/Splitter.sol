pragma solidity ^0.4.24;

contract Splitter {
    address public owner;

    mapping(address => uint) public balances;

    event LogOwner(address indexed owner);
    event LogSplit(address owner, address firstPerson, address secondPerson, uint amount);
    event LogWithdraw(address person, uint amount);

    constructor () public {
        owner = msg.sender;
        emit LogOwner(owner);
    }

    function split(address firstPerson, address secondPerson) public payable {
        require(msg.sender == owner, "You are not the owner!");
        require(msg.value > 0, "The amount is too low!");
        require(firstPerson != address(0), "The address is not set");
        require(secondPerson != address(0), "The address is not set");

        uint256 halfAmount = msg.value / 2;

        if(msg.value % 2 == 1) {
            balances[owner] += 1;
        }
        balances[firstPerson] += halfAmount;
        balances[secondPerson] += halfAmount;

        emit LogSplit(msg.sender, firstPerson, secondPerson, halfAmount);
    }

    function withdraw() public {
        uint amount = balances[msg.sender];
        if(amount > 0) {
            balances[msg.sender] = 0;
            emit LogWithdraw(msg.sender, amount);
            msg.sender.transfer(amount);
        }
    }
}

