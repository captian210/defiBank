// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract DeFiBank {

    uint public deposited;
    uint public lended;

    uint public dividends;


    struct loan {
        uint amount;
        uint time;
    }


    mapping(address => loan) public loans;

    mapping(address => uint256) public deposits;


    function provideLiquidity() public payable {
        deposits[msg.sender] += msg.value;
        deposited += msg.value;
    }

    function getLoan(uint amount) public {

        require(amount <= deposited);

        loans[msg.sender].amount = amount;
        loans[msg.sender].time = block.timestamp;

        lended += amount;

        payable(msg.sender).transfer(amount);

    }

    function payLoan() public payable {

        uint availableLiquidity = deposited - lended;
        uint payment = (deposited * loans[msg.sender].amount) / availableLiquidity;

        require(msg.value >= payment);

        dividends += payment - loans[msg.sender].amount;

        lended -= loans[msg.sender].amount;
        loans[msg.sender].amount -= loans[msg.sender].amount;

    }


    function viewLoanAmount() public view returns (uint) {

        uint availableLiquidity = deposited - lended;
        uint payment = (deposited * loans[msg.sender].amount) / availableLiquidity;

        return payment;

    }


    function withdraw (uint amount) public {

        require(deposits[msg.sender] >= amount);

        deposits[msg.sender] -= amount;
        deposited -= amount;

        payable(msg.sender).transfer(amount);

        }

}
