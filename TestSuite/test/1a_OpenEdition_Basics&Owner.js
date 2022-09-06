const truffleAssert = require('truffle-assertions');

const oe = artifacts.require("OpenEdition");
const dbf = artifacts.require("DummyBalanceContractFalse");
const dbt = artifacts.require("DummyBalanceContractTrue");
const cpc = artifacts.require("CharityProvider");

contract("OpenEdition - Basic Functions", (accounts) => {

    // Contract Import Statements

    // const oec = await oe.deployed();
    // const cp = await cpc.deployed();
    // const f = await dbf.deployed();
    // const t = await dbt.deployed();

    it("Check Default Owner", async () => {
        const oec = await oe.deployed();
        const owner = await oec.owner();
        assert.equal(owner.valueOf(), accounts[0], "Incorrect OwnerOf");
    });

    // Counter Init

    it("Check Counter Inits at Zero", async () => {
        const oec = await oe.deployed();
        const check = await oec.counter();
        assert.equal(check.valueOf(), 0, "Incorrect Counter Value");
    });

    // V3 Requirement

    it("V3Requirement Check", async () => {
        const oec = await oe.deployed();
        const check = await oec.v3RequirementEnabled();
        assert.equal(check.valueOf(), true, "Incorrect v3RequirementEnabled");
    });

    it("setV3Requirement Check", async () => {
        const oec = await oe.deployed();
        await oec.setV3Requirement(false);
        const check = await oec.v3RequirementEnabled();
        assert.equal(check.valueOf(), false, "setV3Requirement doesn't work");
    });

    it("setV3Requirement Check - Non Owner Should Fail", async () => {
        const oec = await oe.deployed();
        await truffleAssert.reverts(
            oec.setV3Requirement(false, { from: accounts[1] }),
            "Ownable: caller is not the owner"
        );

    });

    // V3 Contract Address

    it("Default v3phunks Check", async () => {
        const initiatedAddress = "0xb7D405BEE01C70A9577316C1B9C2505F146e8842";
        const oec = await oe.deployed();
        const check = await oec.v3phunks();
        assert.equal(check.valueOf(), initiatedAddress, "Incorrect v3phunks at init");
    });

    it("setV3ContractAddress Check", async () => {
        const oec = await oe.deployed();
        await oec.setV3ContractAddress(accounts[0]);
        const check = await oec.v3phunks();
        assert.equal(check.valueOf(), accounts[0], "setV3ContractAddress doesn't work");
    });

    it("setV3ContractAddress Check - Non Owner Should Fail", async () => {
        const oec = await oe.deployed();
        await truffleAssert.reverts(
            oec.setV3ContractAddress(accounts[1], { from: accounts[1] }),
            "Ownable: caller is not the owner"
        );

    });

    // charityProvider 

    it("Default charityProvider Check", async () => {
        const initiatedAddress = "0xDF6e46d6a0999a5c0D19C094A11b9d4A03D9C3F9";
        const oec = await oe.deployed();
        const check = await oec.charityProvider();
        assert.equal(check.valueOf(), initiatedAddress, "Incorrect charityProvider at init");
    });

    it("setCharityProvider Check", async () => {
        const oec = await oe.deployed();
        await oec.setCharityProvider(accounts[0]);
        const check = await oec.charityProvider();
        assert.equal(check.valueOf(), accounts[0], "setCharityProvider doesn't work");
    });

    it("setCharityProvider Check - Non Owner Should Fail", async () => {
        const oec = await oe.deployed();
        await truffleAssert.reverts(
            oec.setCharityProvider(accounts[1], { from: accounts[1] }),
            "Ownable: caller is not the owner"
        );

    });

}
);