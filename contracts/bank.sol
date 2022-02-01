// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20/ERC20.sol";

contract DeFiBank is ERC20 {

    uint public deposited;

    uint public lended;

    uint public dividends;

    uint256 public totalReleased;


    // @dev events
    event TotalDeposits(uint amount);
    event TotalLended(uint amount);
    event Deposited(address depositor, uint amount);
    event Loaned(address debtor, uint amount);


    struct Loan {
        uint amount;
        uint time;
    }


    mapping(address => Loan) public loans;

    mapping(address => uint256) public deposits;

    mapping(address => uint256) private released;

    // @dev user deposits funds
    function provideLiquidity() public payable {

        deposits[msg.sender] += msg.value;

        deposited += msg.value;

        _mint(msg.sender, msg.value);

        emit Deposited(msg.sender, msg.value);

        emit TotalDeposits(deposited);

    }

    // @dev user can get loan (currently no collateral i.e. this is for demonstration purposes)
    function getLoan(uint amount) external {

        require(amount <= deposited);

        loans[msg.sender].amount = amount;

        loans[msg.sender].time = block.timestamp;

        lended += amount;

        payable(msg.sender).transfer(amount);

        emit Loaned(msg.sender, amount);

        emit TotalLended(lended);

    }


    // @dev currently loan must be paid in full
    function payLoan() external payable {

        // @dev simple interest 
        
        uint payment = calculateLoan();

        require(msg.value >= payment);

        dividends += msg.value - loans[msg.sender].amount;

        lended -= loans[msg.sender].amount;

        loans[msg.sender].amount -= loans[msg.sender].amount;

        emit TotalLended(lended);

    }

    /* 
    @dev 
    
    interest is a function of available liquidity and the size 
    of the user's loan proportional to total amount loaned out
     
    */
    function viewLoanAmount() external view returns (uint) {

        uint availableLiquidity = deposited - lended;

        uint _loan = loans[msg.sender].amount;

        uint payment = (deposited * _loan) / availableLiquidity;

        uint interest = payment - _loan;

        uint interestC = continuousInterest(interest);

        payment += interestC;

        return payment;

    }
    
    // @dev same function as above but private
    function calculateLoan() private view returns (uint) {

        uint availableLiquidity = deposited - lended;

        uint _loan = loans[msg.sender].amount;

        uint payment = (deposited * _loan) / availableLiquidity;

        uint interest = payment - _loan;

        uint interestC = continuousInterest(interest);

        payment += interestC;

        return payment;

    }



    // @dev this function regulates the rate at which the interest increases
    function continuousInterest(uint interest) private view returns (uint) {

        uint t1 = loans[msg.sender].time;

        uint t2 = block.timestamp;

        uint time = t2 - t1;

        // @ dev interest rate i.e. 2102400 blocks per year
        uint interestC = interest * time / 2102400;

        return interestC;

    }



    // @ dev add functionality: user can send deposit tokens to another address, and withdraw liquidity using ERC20 tokens
    function withdrawLiquidity (uint amount) public {

        require(deposits[msg.sender] >= amount);
        require(balanceOf(msg.sender) >= amount);

        deposits[msg.sender] -= amount;

        deposited -= amount;

        _burn(msg.sender, amount);

        payable(msg.sender).transfer(amount);

        emit TotalDeposits(deposited);

        }

    // @dev users who provided liquidity can withdraw the interest payments proportional to how much liquidity they provided 
    // @dev -- planned feature: depositors can only withdraw proportional to the amount of liquidity they provided & time the liquidity was deposited
    function withdrawEarnings () external virtual {

        require(deposits[msg.sender] > 0, "PaymentSplitter: account has no deposits");

        uint256 totalReceived = dividends + totalReleased;

        uint256 payment = (totalReceived * deposits[msg.sender]) / deposited - released[msg.sender];

        require(payment != 0, "PaymentSplitter: account is not due payment");

        released[msg.sender] += payment;

        totalReleased += payment;

        payable(msg.sender).transfer(payment);

    }

}
