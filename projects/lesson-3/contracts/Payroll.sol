pragma solidity ^0.4.14;

import './SafeMath.sol';
import './Ownable.sol';

contract Payroll is Ownable {

    using SafeMath for uint;

    struct Employee {
        address id;
        uint salary;
        uint lastPayDay;
    }

    uint constant payDuration = 30 days;
    uint public totalSalary = 0;

    address owner;
    mapping(address => Employee) public employees;

    function Payroll() payable public {
        owner = msg.sender;
    }

    modifier employeeExist(address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        _;
    }
    
    function _partitialPaied(Employee employee) private {
        uint curDuration = now.sub(employee.lastPayDay);
        uint payment = employee.salary.mul(curDuration).div(payDuration);
        employee.id.transfer(payment);
    }
    
    function addEmployee(address employeeId, uint salary) onlyOwner public {
        var employee = employees[employeeId];
        assert(employee.id == 0x0);
        
        totalSalary.add(salary * 1 ether);
        employees[employeeId] = Employee(employeeId, salary * 1 ether, now);
    }

    function removeEmployee(address employeeId) onlyOwner employeeExist(employeeId) public {
        var employee = employees[employeeId];
        
        _partitialPaied(employee);
        totalSalary.sub(employees[employeeId].salary);
        delete employees[employeeId];
    }

    function changePaymentAddress(address oldAddress, address newAddress) onlyOwner employeeExist(oldAddress) public {
        var oldemployee = employees[oldAddress];
        
        uint salary = oldemployee.salary;
        
        removeEmployee(oldemployee.id);
        addEmployee(newAddress, salary);
    }

    function updateEmployee(address employeeId, uint salary) onlyOwner employeeExist(employeeId) public {
        var employee = employees[employeeId];

        _partitialPaied(employee);
        totalSalary.sub(employees[employeeId].salary);
        employees[employeeId].salary = salary * 1 ether;
        totalSalary.add(employees[employeeId].salary);
        employees[employeeId].lastPayDay = now;
    }

    function addFund() payable public returns (uint) {
        return address(this).balance;
    }

    function calculateRunway() public view returns (uint) {
        return this.balance / totalSalary;
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    function checkEmployee(address employeeId) returns (uint salary, uint lastPayDay) {
        var employee = employees[employeeId];
        salary = employee.salary;
        lastPayDay = employee.lastPayDay;
    }

    function getPaid() employeeExist(msg.sender) public {
        var employee = employees[msg.sender];

        uint nextPayDay = employee.lastPayDay + payDuration;
        assert(nextPayDay < now);
        
        employees[msg.sender].lastPayDay = nextPayDay;
        employee.id.transfer(employee.salary);
    }
}
