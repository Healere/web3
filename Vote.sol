// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Vote {
    struct Voter {
        uint256 amount;//ticket amount
        bool isVoted;
        address delegator;//agenter address
        uint256 targetId;
    }
    
    struct Board {
        string name;//target name
        uint256 totalAmount;//ticket amount
    }

    // host information
    address public host;

    //create voter map
    mapping(address => Voter)public voters;

    //topic map
    Board[] public board;

    constructor(string [] memory nameList) {
        host = msg.sender;
        voters[host].amount = 1;
        for(uint256 i = 0 ; i < nameList.length;i++){
            Board memory boardItem = Board(nameList[i],0);
            board.push(boardItem);
        }
    }

    function getBoardInfo()public view returns(Board[] memory){
        return board;
    }

    function mandate(address[] calldata addressList)public {
        require(msg.sender == host,"Only the owner has permissions");
        for(uint256 i = 0 ; i < addressList.length; i++){
            if(!voters[addressList[i]].isVoted){
                voters[addressList[i]].amount = 1;
            }
        }
    }

    function vote(uint256 targetId) public {
        Voter storage sender = voters[msg.sender];
        require(sender.amount!=0,"Has no right to vote.");
        require(!sender.isVoted,"Already voted.");
        sender.isVoted = true;
        sender.targetId = targetId;
        board[targetId].totalAmount += sender.amount;
        emit voteSuccess(unicode"vote success");
    }

    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.isVoted,"You has already voted!");
        require(msg.sender != to,"Can not delegate yourself!");
        while(voters[to].delegator != address(0)){
            to = voters[to].delegator;
            require(to==msg.sender,unicode"不能循环授权！");
        }

        sender.isVoted = true;
        sender.delegator = to;

        Voter storage delegator_ = voters[to];
        if(delegator_.isVoted){
            board[delegator_.targetId].totalAmount += sender.amount;
        }else{
            delegator_.amount += sender.amount;
        }
    }

    event voteSuccess(string);
}

/*
["jack","lucy","tom"]
host: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
jack: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
lucy: 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
tom: 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
contrct address: 0x6be86C62b6B0a56eDd7ed3bbB1cc153067543179

robot: 0x617F2E2fD72FD9D5503197092aC168c91465E7f2
smith: 0x17F6AD8Ef982297579C203069C1DbfFE4348c372
jam: 0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678
["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db","0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB"]
["0x617F2E2fD72FD9D5503197092aC168c91465E7f2","0x17F6AD8Ef982297579C203069C1DbfFE4348c372","0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678"]
    {
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4:{
            amount: 1,
            isVoted: false,
            delegator: 0x000000,
            targetId: 1
        },
        0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2:{
            amount: 1,
            isVoted: false,
            delegator: 0x000000,
            targetId: 1
        },
        0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db:{
            amount: 1,
            isVoted: false,
            delegator: 0x000000,
            targetId: 1
        },
        0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB:{
            amount: 1,
            isVoted: false,
            delegator: 0x000000,
            targetId: 1
        },
    }

    [
        {
            name:"jack",
            totalAmount: 10
        },
        {
            name:"lucy",
            totalAmount: 8
        },
    ]

    
*/


