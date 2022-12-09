/* global describe it before ethers */

const { EXTERNAL, INTERNAL, INTERNAL_EXTERNAL, INTERNAL_TOLERANT } = require('./utils/balances')

const { takeSnapshot, revertToSnapshot } = require("./utils/snapshot");

const { deployDiamond } = require('../scripts/deploy.js')

const { expect } = require('chai');
const { ethers } = require('hardhat');
const { BCT, NCT, KLIMA_CARBON_RETIREMENTS } = require('./utils/constants.js');

describe('Toucan Redeem Functions', async function () {

    before(async function () {
        diamond = await deployDiamond()
        redeemFacet = await ethers.getContractAt('RedeemToucanPoolFacet', diamond)
        retireInfoFacet = await ethers.getContractAt('RetireInfoFacet', diamond)

        // Approve token spend for diamond.
        console.log('----Approving Tokens for Spending----')
        abi = ["function approve(address spender, uint256 amount)", "function balanceOf(address) view returns(uint256)"]
        signer = await ethers.getSigner()
        bct = await ethers.getContractAt(abi, BCT, signer)
        nct = await ethers.getContractAt(abi, NCT, signer)

        await bct.approve(diamond, '1000000000000000000000000')
        await nct.approve(diamond, '1000000000000000000000000')

        userAddress = signer.address
        defaultCarbonRetireAmount = '100000000000'
        bctDefaultProjectAddress = '0xb139C4cC9D20A3618E9a2268D73Eff18C496B991'
        nctDefaultProjectAddress = '0x463de2a5c6E8Bb0c87F4Aa80a02689e6680F72C7'
        bctSpecificProjectAddress = '0x35B73A62Dd351030eCBd4252135e59bbb6345a60'
        nctSpecificProjectAddress = '0x04943C19896c776c78770429eC02C5384ee78292'


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
        describe('Redeem BCT', async () => {
            beforeEach(async () => {
                this.result = await redeemFacet.toucan_redeemPoolDefault(BCT,
                    defaultCarbonRetireAmount,
                    EXTERNAL,
                    EXTERNAL)
            })
            it('No tokens left in contract', async () => {
                expect(await bct.balanceOf(redeemFacet.address)).equals(0)
            })
            it('Account state values updated', async () => {
                expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
            })
            it('Caller has TCO2 tokens', async () => {
                tco2 = await ethers.getContractAt(abi, bctDefaultProjectAddress, signer)
                expect(await tco2.balanceOf(signer.address)).equals(defaultCarbonRetireAmount)
            })
        })
        describe('Redeem NCT', async () => {
            beforeEach(async () => {
                this.result = await redeemFacet.toucan_redeemPoolDefault(NCT,
                    defaultCarbonRetireAmount,
                    EXTERNAL,
                    EXTERNAL)
            })
            it('No tokens left in contract', async () => {
                expect(await nct.balanceOf(redeemFacet.address)).equals(0)
            })
            it('Account state values updated', async () => {
                expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
            })
            it('Caller has TCO2 tokens', async () => {
                tco2 = await ethers.getContractAt(abi, nctDefaultProjectAddress, signer)
                expect(await tco2.balanceOf(signer.address)).equals(defaultCarbonRetireAmount)
            })
        })
    })
    describe('External Specific Redemptions', async function () {
        describe('Redeem BCT', async () => {
            beforeEach(async () => {
                this.result = await redeemFacet.toucan_redeemPoolSpecific(BCT,
                    [bctSpecificProjectAddress],
                    [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                    EXTERNAL,
                    EXTERNAL)
            })
            it('No tokens left in contract', async () => {
                expect(await bct.balanceOf(redeemFacet.address)).equals(0)
            })
            it('Account state values updated', async () => {
                expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
            })
            it('Caller has TCO2 tokens', async () => {
                tco2 = await ethers.getContractAt(abi, bctSpecificProjectAddress, signer)
                expect(await tco2.balanceOf(signer.address)).equals(defaultCarbonRetireAmount * .75)
            })
        })
        describe('Redeem NCT', async () => {
            beforeEach(async () => {
                this.result = await redeemFacet.toucan_redeemPoolSpecific(NCT,
                    [nctSpecificProjectAddress],
                    [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                    EXTERNAL,
                    EXTERNAL)
            })
            it('No tokens left in contract', async () => {
                expect(await nct.balanceOf(redeemFacet.address)).equals(0)
            })
            it('Account state values updated', async () => {
                expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
            })
            it('Caller has TCO2 tokens', async () => {
                tco2 = await ethers.getContractAt(abi, nctSpecificProjectAddress, signer)
                expect(await tco2.balanceOf(signer.address)).equals(defaultCarbonRetireAmount * .9)
            })
        })
    })
})
