const dbf = artifacts.require("DummyBalanceContractFalse");

contract("DummyBalanceContractFalse", (accounts) => {
    it("Dummy False Returns 0 Balance", async () => {
        const contract = await dbf.deployed();
        const balance = await contract.balanceOf(accounts[0]);

        assert.equal(balance.valueOf(), 0, "Doesn't Return False");
    });
}
)