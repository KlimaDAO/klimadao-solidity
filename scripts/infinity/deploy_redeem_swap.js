const { getInfinity } = require("../../utils/contracts")
const fs = require('fs');
const { upgradeWithNewFacets } = require("../diamond");
const { INFINITY } = require("../../test/utils/constants");

async function redeemSwap(mock = true, account = undefined) {


    infinity = await getInfinity()
    await upgradeWithNewFacets({
        diamondAddress: INFINITY,
        facetNames: ['RetirementQuoter'],
        // initFacetName: ,
        // initArgs: [],
        // selectorsToRemove: ['0xf0ff264c', '0x79f5e053', '0x7eed24a2'],
        object: !mock,
        verbose: true,
        account: account
    });
}

exports.redeemSwap = redeemSwap
