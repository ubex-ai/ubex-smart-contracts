var AdamCoefficients = artifacts.require("./AdamCoefficients.sol");

contract('AdamCoefficients', function(accounts) {
  it("should be able to store neural network coefficients", async () => {
    const expectedSystemOwner = accounts[1];

    const config = await AdamCoefficients.deployed();

    const actualSystemOwner = await config.systemOwner();

    assert.equal(actualSystemOwner, expectedSystemOwner, "Incorrect system owner");
  })
});
