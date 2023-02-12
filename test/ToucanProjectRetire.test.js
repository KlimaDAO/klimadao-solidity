/* global describe it before ethers */

const { EXTERNAL, INTERNAL, INTERNAL_EXTERNAL, INTERNAL_TOLERANT } = require('./utils/balances')

const { takeSnapshot, revertToSnapshot } = require("./utils/snapshot");

const { deployDiamond } = require('../scripts/deploy.js')

const { assert, expect } = require('chai');
const { ethers } = require('hardhat');
const { USDC, BCT, NCT, KLIMA, SKLIMA, WSKLIMA, ZERO_ADDRESS, KLIMA_CARBON_RETIREMENTS } = require('./utils/constants.js');
const { TOUCAN } = require('./utils/bridges.js');

describe('Toucan TCO2 Functions', async function () {

    before(async function () {
        diamond = await deployDiamond()
        redeemFacet = await ethers.getContractAt('RedeemToucanPoolFacet', diamond)
        retireInfoFacet = await ethers.getContractAt('RetireInfoFacet', diamond)
        retireToucanTCO2 = await ethers.getContractAt('RetireToucanTCO2Facet', diamond)
        tokenFacet = await ethers.getContractAt('TokenFacet', diamond)

        // Approve token spend for diamond.
        console.log('----Approving Tokens for Spending----')
        abi = ["function approve(address spender, uint256 amount)", "function balanceOf(address) view returns(uint256)"]
        signer = await ethers.getSigner()
        usdc = await ethers.getContractAt(abi, USDC, signer)
        klima = await ethers.getContractAt(abi, KLIMA, signer)
        sklima = await ethers.getContractAt(abi, SKLIMA, signer)
        wsklima = await ethers.getContractAt(abi, WSKLIMA, signer)
        bct = await ethers.getContractAt(abi, BCT, signer)
        nct = await ethers.getContractAt(abi, NCT, signer)


        await usdc.approve(diamond, '1000000000000000000000000')
        await klima.approve(diamond, '1000000000000000000000000')
        await sklima.approve(diamond, '1000000000000000000000000')
        await wsklima.approve(diamond, '1000000000000000000000000')
        await bct.approve(diamond, '1000000000000000000000000')
        await nct.approve(diamond, '1000000000000000000000000')

        userAddress = signer.address
        defaultEntity = 'KlimaDAO Retirement Aggregator'
        customEntity = 'The Best Carbon Desk Ever'
        defaultCarbonRetireAmount = BigInt('100000000000')
        bctDefaultProjectAddress = '0xb139C4cC9D20A3618E9a2268D73Eff18C496B991'
        nctDefaultProjectAddress = '0x463de2a5c6E8Bb0c87F4Aa80a02689e6680F72C7'
        bctSpecificProjectAddress = '0x35B73A62Dd351030eCBd4252135e59bbb6345a60'
        nctSpecificProjectAddress = '0x04943C19896c776c78770429eC02C5384ee78292'

        tco2 = await ethers.getContractAt(abi, bctDefaultProjectAddress, signer)
        await tco2.approve(diamond, '1000000000000000000000000')

        storageABI = ["function addHelperContract(address _helper)"]
        klimaStorage = await ethers.getContractAt(storageABI, KLIMA_CARBON_RETIREMENTS)
        await klimaStorage.addHelperContract(diamond)
        currentRetirements = Number(await retireInfoFacet.getTotalRetirements(userAddress))
        currentTotalCarbon = BigInt(await retireInfoFacet.getTotalCarbonRetired(userAddress))
        expectedRetirements = currentRetirements + 1
        expectedCarbonRetired = currentTotalCarbon + defaultCarbonRetireAmount

    })

    beforeEach(async function () {
        snapshotId = await takeSnapshot();
    });

    afterEach(async function () {
        await revertToSnapshot(snapshotId);
    });

    describe('External TCO2 Redemptions', async function () {
        describe('Retire TCO2', async () => {
            beforeEach(async () => {
                beneficiary = 'Test 1'
                message = 'Message 1'
                await redeemFacet.toucan_redeemPoolDefault(BCT, defaultCarbonRetireAmount, EXTERNAL, EXTERNAL)
                this.result = await retireToucanTCO2.toucan_retireExactTCO2(
                    bctDefaultProjectAddress,
                    defaultCarbonRetireAmount,
                    userAddress,
                    beneficiary,
                    message,
                    EXTERNAL
                )
            })
            it('No tokens left in contract', async () => {
                expect(await bct.balanceOf(retireToucanTCO2.address)).equals(0)
            })
            it('Account state values updated', async () => {
                expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
            })
            it('Emits CarbonRetired event', async () => {
                await expect(this.result).to.emit(retireToucanTCO2, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, ZERO_ADDRESS, bctDefaultProjectAddress, defaultCarbonRetireAmount);
            })
        })
    })
})
