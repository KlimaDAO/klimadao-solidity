/* global describe it before ethers */

const { EXTERNAL, INTERNAL, INTERNAL_EXTERNAL, INTERNAL_TOLERANT } = require('./utils/balances')

const { takeSnapshot, revertToSnapshot } = require("./utils/snapshot");

const { deployDiamond } = require('../scripts/deploy.js')

const { assert, expect } = require('chai');
const { ethers } = require('hardhat');
const { USDC, MCO2, KLIMA, SKLIMA, WSKLIMA, ZERO_ADDRESS, KLIMA_CARBON_RETIREMENTS } = require('./utils/constants.js');
const { MOSS } = require('./utils/bridges.js');

describe('Moss Functions', async function () {

    before(async function () {
        // Initial Diamond setup
        diamond = await deployDiamond()
        retireCarbonFacet = await ethers.getContractAt('RetireCarbonFacet', diamond)
        retireSourceFacet = await ethers.getContractAt('RetireSourceFacet', diamond)
        retireInfoFacet = await ethers.getContractAt('RetireInfoFacet', diamond)
        quoter = await ethers.getContractAt('RetirementQuoter', diamond)

        // Approve token spend for diamond.
        console.log('----Approving Tokens for Spending----')
        abi = ["function approve(address spender, uint256 amount)", "function balanceOf(address) view returns(uint256)"]
        signer = await ethers.getSigner()
        usdc = await ethers.getContractAt(abi, USDC, signer)
        klima = await ethers.getContractAt(abi, KLIMA, signer)
        sklima = await ethers.getContractAt(abi, SKLIMA, signer)
        wsklima = await ethers.getContractAt(abi, WSKLIMA, signer)
        mco2 = await ethers.getContractAt(abi, MCO2, signer)

        await usdc.approve(diamond, '1000000000000000000000000')
        await klima.approve(diamond, '1000000000000000000000000')
        await sklima.approve(diamond, '1000000000000000000000000')
        await wsklima.approve(diamond, '1000000000000000000000000')
        await mco2.approve(diamond, '1000000000000000000000000')

        userAddress = signer.address
        defaultProjectAddress = '0xb139C4cC9D20A3618E9a2268D73Eff18C496B991'
        defaultEntity = 'KlimaDAO Retirement Aggregator'
        customEntity = 'The Best Carbon Desk Ever'
        defaultCarbonRetireAmount = BigInt('10000000000000000')

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

    describe('External Exact Carbon Retirements', async function () {
        describe('Default Retirements', async function () {
            describe('Retire MCO2', async () => {
                describe('Using MCO2', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 4'
                        message = 'Message 4'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(MCO2, MCO2, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(MCO2, MCO2, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await mco2.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(MOSS, signer.address, defaultEntity, userAddress, beneficiary, message, MCO2, ZERO_ADDRESS, defaultCarbonRetireAmount);
                    })
                })
                describe('Using USDC', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 5'
                        message = 'Message 5'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(USDC, MCO2, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(USDC, MCO2, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await usdc.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await mco2.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(MOSS, signer.address, defaultEntity, userAddress, beneficiary, message, MCO2, ZERO_ADDRESS, defaultCarbonRetireAmount);
                    })
                })
                describe('Using KLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 6'
                        message = 'Message 6'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(KLIMA, MCO2, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(KLIMA, MCO2, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await mco2.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(MOSS, signer.address, defaultEntity, userAddress, beneficiary, message, MCO2, ZERO_ADDRESS, defaultCarbonRetireAmount);
                    })
                })
                describe('Using sKLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 9'
                        message = 'Message 9'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(SKLIMA, MCO2, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(SKLIMA, MCO2, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await mco2.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(MOSS, signer.address, defaultEntity, userAddress, beneficiary, message, MCO2, ZERO_ADDRESS, defaultCarbonRetireAmount);
                    })
                })
                describe('Using wsKLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 10'
                        message = 'Message 10'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(WSKLIMA, MCO2, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(WSKLIMA, MCO2, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await wsklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await mco2.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(MOSS, signer.address, defaultEntity, userAddress, beneficiary, message, MCO2, ZERO_ADDRESS, defaultCarbonRetireAmount);
                    })
                })
            })
        })
    })
    describe('External Exact Source Retirements', async function () {
        describe('Default Retirements', async function () {
            describe('Retire MCO2', async () => {
                describe('Using MCO2', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 4'
                        message = 'Message 4'
                        this.result = await retireSourceFacet.retireExactSourceDefault(MCO2, MCO2, 1000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await mco2.balanceOf(retireSourceFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).gt(currentTotalCarbon)
                    })
                })
                describe('Using USDC', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 5'
                        message = 'Message 5'
                        this.result = await retireSourceFacet.retireExactSourceDefault(USDC, MCO2, 1000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await usdc.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await mco2.balanceOf(retireSourceFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).gt(currentTotalCarbon)
                    })
                })
                describe('Using KLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 6'
                        message = 'Message 6'
                        this.result = await retireSourceFacet.retireExactSourceDefault(KLIMA, MCO2, 1000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await mco2.balanceOf(retireSourceFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).gt(currentTotalCarbon)
                    })
                })
                describe('Using sKLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 9'
                        message = 'Message 9'
                        this.result = await retireSourceFacet.retireExactSourceDefault(SKLIMA, MCO2, 1000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await mco2.balanceOf(retireSourceFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).gt(currentTotalCarbon)
                    })
                })
                describe('Using wsKLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 10'
                        message = 'Message 10'
                        this.result = await retireSourceFacet.retireExactSourceDefault(WSKLIMA, MCO2, 1000000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await wsklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await mco2.balanceOf(retireSourceFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).gt(currentTotalCarbon)
                    })
                })
            })
        })
    })
})
