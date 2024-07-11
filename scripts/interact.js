async function main() {
    const [deployer] = await ethers.getSigners();
    const contractAddress = "";
    const SecureFundsManager = await ethers.getContractFactory("SecureFundsManager");
    const contract = await SecureFundsManager.attach(contractAddress);

    const addressToAuthorize = "";
    const txAuthorize = await contract.authorizeAddress(addressToAuthorize);
    await txAuthorize.wait();
    console.log("Address authorized:", addressToAuthorize);

    const balance = await deployer.getBalance();
    console.log("Account balance:", ethers.utils.formatEther(balance), "ETH");

    if (balance.lt(ethers.utils.parseEther("0.00002"))) {
        throw new Error("Insufficient funds for sending transaction and gas fees.");
    }

    const recipientAddress = "";
    const amountToSend = ethers.utils.parseEther("0.0001");

    const gasLimit = 21000;

    const txSendFunds = await contract.sendFunds(recipientAddress, amountToSend, { gasLimit });
    await txSendFunds.wait();
    console.log("Funds sent to:", recipientAddress);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
