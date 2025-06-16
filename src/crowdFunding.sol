// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CrowdFunding {
    //State
    address public projectCreator;
    uint public goal;
    uint public deadline;
    uint public amountRaised;
    bool public goalReached;
    bool public creatorWithdrawn;

    mapping(address => uint) public contributions;

    //modifiers

    modifier onlyCreator() {
        require(msg.sender == projectCreator, "Only creator can perform this function");
        _;
    }

    modifier beforeDeadline() {
        require(block.timestamp < deadline, "Deadline passed");
        _;
    }

    modifier afterDeadline() {
        require(block.timestamp >= deadline, "Deadline not reached yet");
        _;
    }
    // Contructors
    constructor(uint _goal, uint _durationInDays) {
        projectCreator = msg.sender;
        goal = _goal;
        deadline = block.timestamp + (_durationInDays * 1 days);
    }
    //Functions

    function contributeFunds() external payable beforeDeadline {
        require(msg.value > 0, "Invalid Amount");

        contributions[msg.sender] += msg.value;
        amountRaised += msg.value;

        if (amountRaised >= goal) {
            goalReached = true;
        }
    }
    function getTotalAmountContributed() public view returns (uint256) {
    return amountRaised;
}

    // function goalReached() external 

    function withdrawFunds() external onlyCreator afterDeadline(){ 
        require(goalReached, "Goal not met");
        require(!creatorWithdrawn, "Funds already withdrawn");
        require(amountRaised >= goal, "Goal not reached");
        
        creatorWithdrawn = true;
        payable(projectCreator).transfer(address(this).balance);
    }

    function refund() external afterDeadline {
        require(!goalReached, "Goal was reached");

        uint amountContributed = contributions[msg.sender];
        require(amountContributed > 0, "invalid request, No contribution to refund");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amountContributed);
    }

    function getTotalAmountContributed(address contributor) external view onlyCreator returns(uint){
            return contributions[contributor];
    }
}
