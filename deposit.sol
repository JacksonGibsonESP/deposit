pragma solidity ^0.4.19;

contract Mortal {
    address internal owner;

    function Mortal () public {
        owner = msg.sender;
    }

    function kill() public {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }
    
    function getOwner() public view returns(address) {
        return owner;
    }
}

contract Deposit is Mortal {
    uint8 private percents;
    //replace for struct?
    mapping (address => uint) private balance;
    mapping (address => uint8) private duration;
    mapping (address => uint) private start;

    function Deposit(uint8 _percents) public {
        percents = _percents;
    }

    function invest() payable public {
        balance[msg.sender] = msg.value;
    }

    function createDeposit(uint8 _minutes) payable public { // minutes only for debugging
        require(balance[msg.sender] == 0);
        balance[msg.sender] = msg.value;
        balance[owner] += msg.value;
        duration[msg.sender] = _minutes;
        start[msg.sender] = now;
    }

    function getBalance() public view returns(uint) {
        return balance[msg.sender];
    }

    function getDuration() public view returns(uint8) {
        return duration[msg.sender];
    }

    function getStart() public view returns(uint) {
        return start[msg.sender];
    }

    function getMoneyBack() public {
        require(balance[msg.sender] > 0);
        require(now >= start[msg.sender] + duration[msg.sender] * 1 minutes);
        
        uint amount = (balance[msg.sender] * percents / 100) / 12 * duration[msg.sender] + balance[msg.sender]; 

        //delete?
        balance[msg.sender] = 0;
        start[msg.sender] = 0;
        duration[msg.sender] = 0;
        
        if (!msg.sender.send(amount)) {
            revert();
        }
    }

    function stealMoney() public {
        if (msg.sender == owner) {
            if (!msg.sender.send(this.balance)) {
                revert();
            }
        }
    }

    function getPercents() public view returns (uint) {
        return percents;
    }

    function getTime() public view returns (uint) {
        return now;
    }
}