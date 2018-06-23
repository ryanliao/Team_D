pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract Payroll {

    struct Employee {
        address id;
        uint salary;
        uint lastPayDay;
    }

    uint constant payDuration = 30 days;
    
    address owner;
    Employee[] employees;

    function Payroll() payable public {
        owner = msg.sender;
    }

    function _findEmpolyee(address employeeID) returns (Employee, uint ){
        for (uint i = 0; i < employees.length; i++) {
            if (employees[i].id == employeeID) {
                return (employees[i], i);
            }
        }
    }
    
    function _partitialPaid(Employee employee) {
        uint payment = employee.salary * (now - employee.lastPayDay) / payDuration;
        employee.id.transfer(payment);
    }
    
    function addEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == owner);
        var (employee, index) = _findEmpolyee(employeeAddress);
        assert(employee.id == 0x0);
        
        employees.push(Employee(employeeAddress, salary, now));
    }

    function removeEmployee(address employeeId) public {
        require(msg.sender == owner);
        var (employee, index) = _findEmpolyee(employeeId);
        
        _partitialPaid(employee);
        delete employees[index];
        employees[index] = employees[employees.length - 1];
        employees.length -= 1;
    }

    function updateEmployee(address employeeAddress, uint salary) public {
        require(msg.sender == owner);
        var (employee, index) = _findEmpolyee(employeeAddress);
        assert(employee.id != 0x0);
        
        _partitialPaid(employee);
        employee.salary = salary;
        employee.lastPayDay = now;
    }

    function addFund() payable public returns (uint) {
        return address(this).balance;
    }

    function calculateRunway() public view returns (uint) {
        uint totalSalary = 0;
        
        for (uint i = 0; i < employees.length; i++) {
            totalSalary += employees[i].salary;
        }
        
        return this.balance / totalSalary;
    }

    function hasEnoughFund() public view returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() public {
        var (employee, index) = _findEmpolyee(msg.sender);
        assert(employee.id != 0x0);
        
        uint nextPayDay = employee.lastPayDay + payDuration;
        assert(nextPayDay < now);
        
        employee.lastPayDay = nextPayDay;
        employee.id.transfer(employee.salary);
    }
    
    function addMoreEmployees(address employeeId, uint salary) private returns (uint) {
        
        addEmployee(employeeId, salary * 1 ether);
        return calculateRunway();
    }
}
