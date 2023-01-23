// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract EventContract{
    struct Event{
        address organizer;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketremain;
    }
    mapping(uint=>Event) public events;
    mapping(address=>mapping(uint=>uint)) public tickets;
    uint public nextEvent;

    function createEvent(string memory name, uint date, uint price, uint ticketCount) external{
        require(date>block.timestamp,"You can create the event for future date");
        require(ticketCount>0,"Ticket count should be greater than 0");
        events[nextEvent] = Event(msg.sender,name,date,price,ticketCount,ticketCount);
        nextEvent++;
    }

    function buyTicket(uint id, uint quantity) external payable{
        require(events[id].date!=0,"Event does not exist");
        require(events[id].date>block.timestamp,"Event already occured");
        Event storage _event = events[id];
        require(msg.value==(_event.price*quantity),"Money is not enogh");
        require(_event.ticketremain>=quantity,"Ticket is not enough");
        _event.ticketremain -=quantity;
        tickets[msg.sender][id]+=quantity;
    }
    function transferTicket(uint eventId, uint quantity, address to) external{
        require(events[eventId].date!=0,"Event does not exist");
        require(events[eventId].date>block.timestamp,"Event already occured");
        require(tickets[msg.sender][eventId]>=quantity,"You don't have enough quantity");
        tickets[msg.sender][eventId]-=quantity;
        tickets[to][eventId]+=quantity;
    }
}
