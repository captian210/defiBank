// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./ERC20/ERC20.sol";

contract DeFiBank is ERC20 {

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

        _mint(msg.sender, msg.value);

    }


    function getLoan(uint amount) public {

        require(amount <= deposited);

        loans[msg.sender].amount = amount;

        loans[msg.sender].time = block.timestamp;

        lended += amount;

        payable(msg.sender).transfer(amount);

    }


    // @dev currently loan must be paid in full
    function payLoan() public payable {

        // @dev simple interest 
        
        uint payment = viewLoanAmount();

        require(msg.value >= payment);

        dividends += msg.value - loans[msg.sender].amount;

        lended -= loans[msg.sender].amount;

        loans[msg.sender].amount -= loans[msg.sender].amount;

    }


    function viewLoanAmount() public view returns (uint) {

        uint availableLiquidity = deposited - lended;

        uint _loan = loans[msg.sender].amount;

        uint payment = (deposited * _loan) / availableLiquidity;

        uint interest = payment - _loan;

        uint interestC = continuousInterest(interest);

        payment += interestC;

        return payment;

    }


    function continuousInterest(uint interest) private view returns (uint) {

        uint t1 = loans[msg.sender].time;

        uint t2 = block.timestamp;

        uint time = t2 - t1;

        // @ dev interest rate i.e. 2102400 blocks per year
        uint interestC = interest * time / 2102400;

        return interestC;

    }


    function withdrawLiquidity (uint amount) public {

        require(deposits[msg.sender] >= amount);

        deposits[msg.sender] -= amount;

        deposited -= amount;

        _burn(msg.sender, amount);

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
