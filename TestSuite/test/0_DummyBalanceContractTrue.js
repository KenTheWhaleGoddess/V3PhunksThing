const dbt = artifacts.require("DummyBalanceContractTrue");

contract("DummyBalanceContractTrue", (accounts) => {
    it("Dummy True Returns 1 Balance", async () => {
        const contract = await dbt.deployed();
        const balance = await contract.balanceOf(accounts[0]);

        assert.equal(balance.valueOf(), 1, "Doesn't Return True");
    });
}
)