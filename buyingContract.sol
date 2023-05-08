// SPDX-License-Identifier : MIT

 pragma solidity 0.8.17;

 // once the money is complete, this contract will buy food -- which is the main essence of the DAO

  contract BuyingContract {

    address public owner;

    mapping(address => uint) public foodBalance;

    constructor () {
        owner = msg.sender;
        foodBalance[address(this)] = 100;
    }

    function increaseBalance(uint amount) public {
        require(msg.sender == owner, "Only the owner can increase the balance");

        foodBalance[address(this)] += amount;
    }

    function buyFood(uint amount) public payable{
        require(msg.value >= 1 ether, "You must pay at least 1 Ether per food");
        require(foodBalance[address(this)] >= amount, "No enough food to complete this order though");
        
        foodBalance[address(this)] -= amount;
        foodBalance[msg.sender] += amount;

    }

  }
