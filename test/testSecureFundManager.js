const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SecureFundManager contract", function () {
    let owner, addr1, addr2, contract;

    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();

        const SecureFundManager = await ethers.getContractFactory("SecureFundManager");
        contract = await SecureFundManager.deploy(owner.address);
        await contract.deployed();
    });

    it("Should receive funds and emit FundsReceived event", async function () {
        const amount = ethers.utils.parseEther("0.00001");
        await expect(addr1.sendTransaction({ to: contract.address, value: amount }))
            .to.emit(contract, "FundsReceived")
            .withArgs(addr1.address, amount);
    });

    it("Should add and remove authorized addresses", async function () {
        await contract.addAuthorizedAddress(addr1.address);
        expect(await contract.getAuthorizedAddressCount()).to.equal(1);
        expect(await contract.getAuthorizedAddress(0)).to.equal(addr1.address);

        await contract.removeAuthorizedAddress(addr1.address);
        expect(await contract.getAuthorizedAddressCount()).to.equal(0);
    });

    it("Should allow authorized addresses to transfer funds with valid signature", async function () {
        const amount = ethers.utils.parseEther("0.00001");
        await addr1.sendTransaction({ to: contract.address, value: amount });

        await contract.addAuthorizedAddress(addr1.address);
        const nonce = ethers.utils.formatBytes32String("1");
        const messageHash = ethers.utils.solidityKeccak256(
            ["address", "uint256", "bytes32", "address"],
            [addr2.address, amount, nonce, contract.address]
        );
        const ethSignedMessageHash = ethers.utils.hashMessage(ethers.utils.arrayify(messageHash));
        const signature = await owner.signMessage(ethSignedMessageHash);

        await expect(contract.connect(addr1).transferFunds(addr2.address, amount, nonce, signature))
            .to.emit(contract, "FundsTransferred")
            .withArgs(addr2.address, amount, addr1.address);
    });

    it("Should reject transfers with invalid signature", async function () {
        const amount = ethers.utils.parseEther("0.00001");
        await addr1.sendTransaction({ to: contract.address, value: amount });

        await contract.addAuthorizedAddress(addr1.address);
        const nonce = ethers.utils.formatBytes32String("1");
        const messageHash = ethers.utils.solidityKeccak256(
            ["address", "uint256", "bytes32", "address"],
            [addr2.address, amount, nonce, contract.address]
        );
        const ethSignedMessageHash = ethers.utils.hashMessage(ethers.utils.arrayify(messageHash));
        const invalidSignature = await addr1.signMessage(ethers.utils.arrayify(ethSignedMessageHash));

        await expect(
            contract.connect(addr1).transferFunds(addr2.address, amount, nonce, invalidSignature)
        ).to.be.revertedWith("Invalid signature");
    });

    it("Should reject transfers with reused nonce", async function () {
        const amount = ethers.utils.parseEther("0.00001");
        await addr1.sendTransaction({ to: contract.address, value: amount });

        await contract.addAuthorizedAddress(addr1.address);
        const nonce = ethers.utils.formatBytes32String("1");
        const messageHash = ethers.utils.solidityKeccak256(
            ["address", "uint256", "bytes32", "address"],
            [addr2.address, amount, nonce, contract.address]
        );
        const ethSignedMessageHash = ethers.utils.hashMessage(ethers.utils.arrayify(messageHash));
        const signature = await owner.signMessage(ethSignedMessageHash);

        await contract.connect(addr1).transferFunds(addr2.address, amount, nonce, signature);

        await expect(
            contract.connect(addr1).transferFunds(addr2.address, amount, nonce, signature)
        ).to.be.revertedWith("Nonce already used");
    });
});
