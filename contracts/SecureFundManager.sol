// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecureFundsManager {
    address public owner;
    mapping(address => bool) private authorizedAddresses;
    address[] private authorizedList;

    event FundsReceived(address indexed from, uint256 amount);
    event FundsSent(address indexed to, uint256 amount);
    event AddressAuthorized(address indexed addr);
    event AddressRevoked(address indexed addr);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyAuthorized() {
        require(authorizedAddresses[msg.sender], "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }

    function sendFunds(address payable _to, uint256 _amount) external onlyAuthorized {
        require(address(this).balance >= _amount, "Insufficient funds");
        _to.transfer(_amount);
        emit FundsSent(_to, _amount);
    }

    function authorizeAddress(address _addr) external onlyOwner {
        require(!authorizedAddresses[_addr], "Already authorized");
        authorizedAddresses[_addr] = true;
        authorizedList.push(_addr);
        emit AddressAuthorized(_addr);
    }

    function revokeAddress(address _addr) external onlyOwner {
        require(authorizedAddresses[_addr], "Not authorized");
        authorizedAddresses[_addr] = false;
        for (uint256 i = 0; i < authorizedList.length; i++) {
            if (authorizedList[i] == _addr) {
                authorizedList[i] = authorizedList[authorizedList.length - 1];
                authorizedList.pop();
                break;
            }
        }
        emit AddressRevoked(_addr);
    }

    function getAuthorizedAddresses() external view returns (address[] memory) {
        return authorizedList;
    }
}
