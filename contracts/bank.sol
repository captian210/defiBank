// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract DeFiBank {

    uint public deposited;
    uint public lended;

    uint public dividends;

    uint256 public totalReleased;


    struct loan {
        uint amount;
        uint time;
    }


    mapping(address => loan) public loans;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) private released;


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


    function withdrawLiquidity (uint amount) public {

        require(deposits[msg.sender] >= amount);

        deposits[msg.sender] -= amount;
        deposited -= amount;

        payable(msg.sender).transfer(amount);

        }


    function withdrawEarnings () public virtual {
        require(deposits[msg.sender] > 0, "PaymentSplitter: account has no deposits");

        uint256 totalReceived = dividends + totalReleased;
        uint256 payment = (totalReceived * deposits[msg.sender]) / deposited - released[msg.sender];

        require(payment != 0, "PaymentSplitter: account is not due payment");

        released[msg.sender] += payment;
        totalReleased += payment;

        payable(msg.sender).transfer(payment);

    }

}
