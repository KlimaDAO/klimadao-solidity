const fs = require('fs');
const infinityABI = require("../abi/KlimaInfinity.json");
const { INFINITY } = require('../test/utils/constants');

async function getInfinity() {
    return await ethers.getContractAt(infinityABI, INFINITY);
}

exports.getInfinity = getInfinity;
