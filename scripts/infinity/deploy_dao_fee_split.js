const { getInfinity } = require("../../utils/contracts")
const fs = require('fs');
const { upgradeWithNewFacets } = require("../diamond");
const { INFINITY } = require("../../test/utils/constants");

// const EVENTS_JSON = './scripts/path-to-data.json'

async function daoFeeUpgrade(mock = true, account = undefined) {

    infinity = await getInfinity()
    await upgradeWithNewFacets({
        diamondAddress: INFINITY,
        facetNames: [
            'RedeemC3PoolFacet',
            'RetireC3C3TFacet',
            'RedeemToucanPoolFacet',
            'RetireToucanTCO2Facet',
            'RetireCarbonFacet',
            'RetireSourceFacet'
        ],
        initFacetName: 'InitProjectTotals',
        // initArgs: [],
        selectorsToRemove: ['0x2687d2f1', '0xb1d2b058', '0xa9f2bd90', '0x72d09fe2'],
        object: !mock,
        verbose: true,
        account: account
    });
}

exports.daoFeeUpgrade = daoFeeUpgrade
