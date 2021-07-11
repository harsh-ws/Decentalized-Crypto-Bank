// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "./Token.sol";

contract dBank {

  //assign Token contract to variable
  Token private token;

  //add mappings
  mapping(address => uint) public etherBalanceOf;
  mapping(address => uint) public depositStart;
  mapping(address => bool) public isDeposited;
  //add events
  event Deposit(address indexed user, uint etherAmount, uint timeStart);
  event Withdraw(address indexed user, uint etherAmount, uint depositTime, uint interest);
  //pass as constructor argument deployed Token contract
  constructor(Token _token) public {
    //assign token deployed contract to variable
    token = _token;
  }

  function deposit() payable public {
    //check if msg.sender didn't already deposited funds
    require(isDeposited[msg.sender]==false, 'Error, deposit already active');
    
    //check if msg.value is >= than 0.01 ETH
    require(msg.value>=1e16, 'Error, deposit must be >= 0.01 ETH');

    
    etherBalanceOf[msg.sender] = etherBalanceOf[msg.sender]  + msg.value;
    //increase msg.sender ether deposit balance

    //start msg.sender hodling time
    depositStart[msg.sender] = depositStart[msg.sender]  + block.timestamp;
    //set msg.sender deposit status to true
    isDeposited[msg.sender]=true;
    //emit Deposit event
    emit Deposit(msg.sender, msg.value, block.timestamp);
  }

  function withdraw() public{
    require(isDeposited[msg.sender]==true, 'Error, no previous deposit');
    uint userBalance = etherBalanceOf[msg.sender];
    uint depositTime = block.timestamp - depositStart[msg.sender];
        //calc interest per second
    uint interestPerSecond = 31668017 * (etherBalanceOf[msg.sender]/1e16);
    //calc accrued interest
    uint interest = interestPerSecond * depositTime;
        //send eth to user
    msg.sender.transfer(userBalance);
    //send interest in tokens to user
    token.mint(msg.sender, interest);
    depositStart[msg.sender]=0;
    etherBalanceOf[msg.sender]=0;
    isDeposited[msg.sender]=false;
    //emit event
    emit Withdraw(msg.sender, userBalance, depositTime, interest);
  }
  function borrow() payable public {
  }

  function payOff() public {

  }
}