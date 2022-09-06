const truffleAssert = require('truffle-assertions');

const oe = artifacts.require("OpenEdition");
const dbf = artifacts.require("DummyBalanceContractFalse");
const dbt = artifacts.require("DummyBalanceContractTrue");
const cpc = artifacts.require("CharityProvider");

contract("OpenEdition - Drops", (accounts) => {

    // Contract Import Statements

    // const oec = await oe.deployed();
    // const cp = await cpc.deployed();
    // const f = await dbf.deployed();
    // const t = await dbt.deployed();

    it("Basic Setup Checks", async () => {
        try {
            await oe.deployed();
            await cpc.deployed();
            await dbf.deployed();
            await dbt.deployed();
            assert.equal(1, 1, ".");
            
        } catch (error) {
            assert.equal(0, 1, "Failed to setup base contracts");
        }

    });

}
);