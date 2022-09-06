const cpc = artifacts.require("CharityProvider");

contract("CharityProvider", (accounts) => {

    it("Check isCharity Defaults False", async () => {
        const contract = await cpc.deployed();
        const isCharity = await contract.isCharity(accounts[0]);

        assert.equal(isCharity.valueOf(), false, "isCharity Doesn't Return False");
    });

    it("Check isEnsCharity Defaults False", async () => {
        const contract = await cpc.deployed();
        const isEnsCharity = await contract.isEnsCharity("theblockchain.eth");

        assert.equal(isEnsCharity.valueOf(), false, "isEnsCharity Doesn't Return False");
    });

    // Non ENS Charities

    it("Can Add Charity To addCharities", async () => {
        const contract = await cpc.deployed();
        await contract.addCharities([accounts[0]]);
        
        const isCharity = await contract.isCharity(accounts[0]);

        assert.equal(isCharity.valueOf(), true, "Cannot insert via addCharities");
    });

    it("Can Add Charity To addCharities Then Remove it via removeCharities", async () => {
        const contract = await cpc.deployed();
        await contract.addCharities([accounts[0]]);
        
        const isCharityCheck1 = await contract.isCharity(accounts[0]);

        await contract.removeCharities([accounts[0]]);
        const isCharityCheck2 = await contract.isCharity(accounts[0]);


        assert.notEqual(isCharityCheck1.valueOf(), isCharityCheck2.valueOf(), "Add then Remove didnt change any states");
    });

    it("Can Add Multiple Charities To addCharities", async () => {
        const contract = await cpc.deployed();
        await contract.addCharities([accounts[0], accounts[1]]);
        
        const isCharityAcc0 = await contract.isCharity(accounts[0]);
        const isCharityAcc1 = await contract.isCharity(accounts[1]);

        var checkedBothAccountsAreTrue = false;

        if(isCharityAcc0.valueOf() && isCharityAcc1.valueOf()) {
            checkedBothAccountsAreTrue = true;
        }

        assert.equal(checkedBothAccountsAreTrue, true, "One, or both, accounts didn't update");
    });

    

    it("Can Add Multiple Charities To addCharities Then Delete Them Too", async () => {
        const contract = await cpc.deployed();
        await contract.addCharities([accounts[0], accounts[1]]);
        
        const isCharityAcc0 = await contract.isCharity(accounts[0]);
        const isCharityAcc1 = await contract.isCharity(accounts[1]);

        var checkedBothAccountsAreTrue = false;

        if(isCharityAcc0.valueOf() && isCharityAcc1.valueOf()) {
            checkedBothAccountsAreTrue = true;
        }

        await contract.removeCharities([accounts[0], accounts[1]]);
        
        const isCharityAcc0_postDelete = await contract.isCharity(accounts[0]);
        const isCharityAcc1_postDelete = await contract.isCharity(accounts[1]);

        var checkedBothAccountsAreRemoved = false;

        if(!isCharityAcc0_postDelete.valueOf() && !isCharityAcc1_postDelete.valueOf()) {
            checkedBothAccountsAreRemoved = true;
        }

        if(checkedBothAccountsAreTrue && checkedBothAccountsAreRemoved) {
            assert.equal(checkedBothAccountsAreTrue, checkedBothAccountsAreRemoved, "Both didn't hit");
        } else {
            assert.equal(0, 1, "One or more accounts either persisted post delete or didn't create");
        }
        
    });

    // ENS Charities

    it("Can Add ENS Charity To addCharitiesEns", async () => {
        const contract = await cpc.deployed();
        await contract.addCharitiesEns(["account1.eth"]);
        
        const isEnsCharity = await contract.isEnsCharity("account1.eth");

        assert.equal(isEnsCharity.valueOf(), true, "Cannot insert via addCharities");
    });

    it("Can Add ENS Charity To addCharitiesEns Then Remove it via removeCharitiesEns", async () => {
        const contract = await cpc.deployed();
        await contract.addCharitiesEns(["account1.eth"]);
        
        const isCharityCheck1 = await contract.isEnsCharity("account1.eth");

        await contract.removeCharitiesEns(["account1.eth"]);
        const isCharityCheck2 = await contract.isEnsCharity("account1.eth");


        assert.notEqual(isCharityCheck1.valueOf(), isCharityCheck2.valueOf(), "Add then Remove didnt change any states");
    });

    it("Can Add Multiple Charities To addCharitiesEns", async () => {
        const contract = await cpc.deployed();
        await contract.addCharitiesEns(["account1.eth", "account2.eth"]);
        
        const isCharityAcc0 = await contract.isEnsCharity("account1.eth");
        const isCharityAcc1 = await contract.isEnsCharity("account2.eth");

        var checkedBothAccountsAreTrue = false;

        if(isCharityAcc0.valueOf() && isCharityAcc1.valueOf()) {
            checkedBothAccountsAreTrue = true;
        }

        assert.equal(checkedBothAccountsAreTrue, true, "One, or both, accounts didn't update");
    });

    

    it("Can Add Multiple Charities To addCharitiesEns Then Delete Them Too", async () => {
        const contract = await cpc.deployed();
        await contract.addCharitiesEns(["account1.eth", "account2.eth"]);
        
        const isCharityAcc0 = await contract.isEnsCharity("account1.eth");
        const isCharityAcc1 = await contract.isEnsCharity("account2.eth");

        var checkedBothAccountsAreTrue = false;

        if(isCharityAcc0.valueOf() && isCharityAcc1.valueOf()) {
            checkedBothAccountsAreTrue = true;
        }

        await contract.removeCharitiesEns(["account1.eth", "account2.eth"]);
        
        const isCharityAcc0_postDelete = await contract.isEnsCharity("account1.eth");
        const isCharityAcc1_postDelete = await contract.isEnsCharity("account2.eth");

        var checkedBothAccountsAreRemoved = false;

        if(!isCharityAcc0_postDelete.valueOf() && !isCharityAcc1_postDelete.valueOf()) {
            checkedBothAccountsAreRemoved = true;
        }

        if(checkedBothAccountsAreTrue && checkedBothAccountsAreRemoved) {
            assert.equal(checkedBothAccountsAreTrue, checkedBothAccountsAreRemoved, "Both didn't hit");
        } else {
            assert.equal(0, 1, "One or more accounts either persisted post delete or didn't create");
        }
        
    });

}
)