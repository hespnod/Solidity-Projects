// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract crowdfunding{
    mapping(address=>uint) public contributors;
    address public manager;
    uint public minContribution;
    uint public target;
    uint public deadline;
    uint public raisedAmount;
    uint public numberOfContributors;

    struct Request{
        string description;
        address payable recepient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }

    mapping(uint=>Request) public request;
    uint public noOfrequest;

    modifier onlymanager(){
        require(msg.sender==manager,"You're not a manager");
        _;
    }
    function createRequests(string memory _description,address payable _recepient,uint _value) public onlymanager{
        Request storage newRequest = request[noOfrequest];
        noOfrequest++;
        newRequest.description = _description;
        newRequest.recepient = _recepient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    constructor(uint _target, uint _deadline){
        target = _target;
        deadline = block.timestamp + _deadline;
        minContribution = 100 wei;
        manager = msg.sender;
    }
    function sendEth() public payable{
        require(block.timestamp<deadline,"Deadline is met");
        require(msg.value>=minContribution,"Minimum contribution is not met");

        if(contributors[msg.sender]==0){
            numberOfContributors++;
    }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;

    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    function refund() public{
        require(block.timestamp>deadline && raisedAmount<target ,"Deadline is not met or target is already met");
        require(contributors[msg.sender]!=0,"You haven't donated anything");
        address payable reciever = payable(msg.sender);
        reciever.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }

    function voteRequest(uint requestNo) public{
        require(contributors[msg.sender]!=0,"You must be a contributor for voting");
        Request storage thisRequest = request[requestNo];
        require(thisRequest.voters[msg.sender]==false,"You have already voted");
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }

    function makePayment(uint requestNo) public onlymanager{
        require(raisedAmount>=target,"Target is not met");
        Request storage newRequest = request[requestNo];
        require(newRequest.completed==false,"Payment has already been done");
        require(newRequest.noOfVoters>=numberOfContributors/2,"Majority is not with you");
        newRequest.recepient.transfer(newRequest.value);
        newRequest.completed = true;
    }

}
