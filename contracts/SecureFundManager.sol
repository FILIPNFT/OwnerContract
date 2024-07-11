// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title SecureFundsManager
/// @notice This contract allows the owner to securely manage and transfer funds.
/// @dev The contract includes mechanisms for authorizing addresses and emitting events on fund transfers.
contract SecureFundsManager {
    /// @notice The address of the contract owner.
    address public owner;

    /// @notice Mapping of authorized addresses.
    mapping(address => bool) private authorizedAddresses;

    /// @notice List of authorized addresses for easy iteration.
    address[] private authorizedList;

    /// @notice Emitted when the contract receives funds.
    /// @param from The address sending the funds.
    /// @param amount The amount of funds received.
    event FundsReceived(address indexed from, uint256 amount);

    /// @notice Emitted when funds are sent from the contract.
    /// @param to The address receiving the funds.
    /// @param amount The amount of funds sent.
    event FundsSent(address indexed to, uint256 amount);

    /// @notice Emitted when an address is authorized.
    /// @param addr The address that was authorized.
    event AddressAuthorized(address indexed addr);

    /// @notice Emitted when an address is revoked.
    /// @param addr The address that was revoked.
    event AddressRevoked(address indexed addr);

    /// @notice Modifier to restrict function access to the owner.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    /// @notice Modifier to restrict function access to authorized addresses.
    modifier onlyAuthorized() {
        require(authorizedAddresses[msg.sender], "Not authorized");
        _;
    }

    /// @notice Constructor that sets the deployer as the owner.
    constructor() {
        owner = msg.sender;
    }

    /// @notice Function to receive ETH. Emits FundsReceived event.
    receive() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }

    /// @notice Sends funds to a specified address.
    /// @dev Only authorized addresses can call this function.
    /// @param _to The recipient address.
    /// @param _amount The amount of ETH to send.
    function sendFunds(address payable _to, uint256 _amount) external onlyAuthorized {
        require(address(this).balance >= _amount, "Insufficient funds");
        _to.transfer(_amount);
        emit FundsSent(_to, _amount);
    }

    /// @notice Authorizes an address to manage funds.
    /// @dev Only the owner can call this function.
    /// @param _addr The address to authorize.
    function authorizeAddress(address _addr) external onlyOwner {
        require(!authorizedAddresses[_addr], "Already authorized");
        authorizedAddresses[_addr] = true;
        authorizedList.push(_addr);
        emit AddressAuthorized(_addr);
    }

    /// @notice Revokes an address's authorization.
    /// @dev Only the owner can call this function.
    /// @param _addr The address to revoke.
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

    /// @notice Returns the list of authorized addresses.
    /// @return An array of authorized addresses.
    function getAuthorizedAddresses() external view returns (address[] memory) {
        return authorizedList;
    }
}
