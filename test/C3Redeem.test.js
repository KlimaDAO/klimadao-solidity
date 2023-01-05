/* global describe it before ethers */

const { EXTERNAL, INTERNAL, INTERNAL_EXTERNAL, INTERNAL_TOLERANT } = require('./utils/balances')

const { takeSnapshot, revertToSnapshot } = require("./utils/snapshot");

const { deployDiamond } = require('../scripts/deploy.js')

const { expect } = require('chai');
const { ethers } = require('hardhat');
const { UBO, NBO, KLIMA_CARBON_RETIREMENTS } = require('./utils/constants.js');

describe('C3 Redeem Functions', async function () {

    before(async function () {
        diamond = await deployDiamond()
        redeemFacet = await ethers.getContractAt('RedeemC3PoolFacet', diamond)
        retireInfoFacet = await ethers.getContractAt('RetireInfoFacet', diamond)

        // Approve token spend for diamond.
        console.log('----Approving Tokens for Spending----')
        abi = ["function approve(address spender, uint256 amount)", "function balanceOf(address) view returns(uint256)"]
        signer = await ethers.getSigner()
        ubo = await ethers.getContractAt(abi, UBO, signer)
        nbo = await ethers.getContractAt(abi, NBO, signer)

        await ubo.approve(diamond, '1000000000000000000000000')
        await nbo.approve(diamond, '1000000000000000000000000')

        userAddress = signer.address
        defaultCarbonRetireAmount = '100000000000'
        uboDefaultProjectAddress = '0xD6Ed6fAE5b6535CAE8d92f40f5FF653dB807A4EA'
        nboDefaultProjectAddress = '0xb6eA7a53FC048D6d3B80b968D696E39482B7e578'
        uboSpecificProjectAddress = '0xD6Ed6fAE5b6535CAE8d92f40f5FF653dB807A4EA'
        nboSpecificProjectAddress = '0xD28DFEBa8fB9e44B715156162C8b6076d7a95Ad1'

        storageABI = ["function addHelperContract(address _helper)"]
        klimaStorage = await ethers.getContractAt(storageABI, KLIMA_CARBON_RETIREMENTS)
        await klimaStorage.addHelperContract(diamond)
        currentRetirements = Number(await retireInfoFacet.getTotalRetirements(userAddress))
        currentTotalCarbon = BigInt(await retireInfoFacet.getTotalCarbonRetired(userAddress))
    })

    beforeEach(async function () {
        snapshotId = await takeSnapshot();
    });

    afterEach(async function () {
        await revertToSnapshot(snapshotId);
    });

    describe('External Default Redemptions', async function () {
        describe('Redeem UBO', async () => {
            beforeEach(async () => {
                this.result = await redeemFacet.c3_redeemPoolDefault(UBO,
                    defaultCarbonRetireAmount,
                    EXTERNAL,
                    EXTERNAL)
            })
            it('No tokens left in contract', async () => {
                tco2 = await ethers.getContractAt(abi, uboDefaultProjectAddress, signer)
                expect(await ubo.balanceOf(redeemFacet.address)).equals(0)
                expect(await tco2.balanceOf(redeemFacet.address)).equals(0)
            })
            it('Account state values updated', async () => {
                expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
            })
            it('Caller has TCO2 tokens', async () => {
                tco2 = await ethers.getContractAt(abi, uboDefaultProjectAddress, signer)
                expect(await tco2.balanceOf(signer.address)).equals(defaultCarbonRetireAmount)
            })
        })
        describe('Redeem NBO', async () => {
            beforeEach(async () => {
                this.result = await redeemFacet.c3_redeemPoolDefault(NBO,
                    defaultCarbonRetireAmount,
                    EXTERNAL,
                    EXTERNAL)
            })
            it('No tokens left in contract', async () => {
                expect(await nbo.balanceOf(redeemFacet.address)).equals(0)
            })
            it('Account state values updated', async () => {
                expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
            })
            it('Caller has TCO2 tokens', async () => {
                tco2 = await ethers.getContractAt(abi, nboDefaultProjectAddress, signer)
                expect(await tco2.balanceOf(signer.address)).equals(defaultCarbonRetireAmount)
            })
        })
    })
    describe('External Specific Redemptions', async function () {
        describe('Redeem UBO', async () => {
            beforeEach(async () => {
                this.result = await redeemFacet.c3_redeemPoolSpecific(UBO,
                    [uboSpecificProjectAddress],
                    [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                    EXTERNAL,
                    EXTERNAL)
            })
            it('No tokens left in contract', async () => {
                expect(await ubo.balanceOf(redeemFacet.address)).equals(0)
            })
            it('Account state values updated', async () => {
                expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
            })
            it('Caller has TCO2 tokens', async () => {
                tco2 = await ethers.getContractAt(abi, uboSpecificProjectAddress, signer)
                expect(await tco2.balanceOf(signer.address)).equals(defaultCarbonRetireAmount)
            })
        })
        describe('Redeem NBO', async () => {
            beforeEach(async () => {
                this.result = await redeemFacet.c3_redeemPoolSpecific(NBO,
                    [nboSpecificProjectAddress],
                    [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                    EXTERNAL,
                    EXTERNAL)
            })
            it('No tokens left in contract', async () => {
                expect(await nbo.balanceOf(redeemFacet.address)).equals(0)
            })
            it('Account state values updated', async () => {
                expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
            })
            it('Caller has TCO2 tokens', async () => {
                tco2 = await ethers.getContractAt(abi, nboSpecificProjectAddress, signer)
                expect(await tco2.balanceOf(signer.address)).equals(defaultCarbonRetireAmount)
            })
        })
    })
})
