# SecureFundsManager Smart Contract

This project contains a Solidity smart contract for managing and transferring funds securely. It allows the owner to authorize addresses that can manage funds and emit events when funds are received or sent.

## Features

- Receive and send native coins (ETH).
- Emit events upon receiving and sending funds.
- Authorize and revoke addresses with O(1) complexity.
- Ensure authorized addresses can send funds using the owner's signature.

## Prerequisites

- Node.js (v14.x or v18.x recommended)
- npm (Node Package Manager)
- Hardhat
- Alchemy API Key
- Etherscan API Key
