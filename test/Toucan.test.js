/* global describe it before ethers */

const { EXTERNAL, INTERNAL, INTERNAL_EXTERNAL, INTERNAL_TOLERANT } = require('./utils/balances')

const { takeSnapshot, revertToSnapshot } = require("./utils/snapshot");

const { deployDiamond } = require('../scripts/deploy.js')

const { assert, expect } = require('chai');
const { ethers } = require('hardhat');
const { USDC, BCT, NCT, KLIMA, SKLIMA, WSKLIMA, KLIMA_CARBON_RETIREMENTS, WMATIC } = require('./utils/constants.js');
const { TOUCAN } = require('./utils/bridges.js');

describe('Toucan Functions', async function () {

    before(async function () {
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
        wmatic = await ethers.getContractAt(abi, WMATIC, signer)
        klima = await ethers.getContractAt(abi, KLIMA, signer)
        sklima = await ethers.getContractAt(abi, SKLIMA, signer)
        wsklima = await ethers.getContractAt(abi, WSKLIMA, signer)
        bct = await ethers.getContractAt(abi, BCT, signer)
        nct = await ethers.getContractAt(abi, NCT, signer)

        await usdc.approve(diamond, '1000000000000000000000000')
        await wmatic.approve(diamond, '1000000000000000000000000')
        await klima.approve(diamond, '1000000000000000000000000')
        await sklima.approve(diamond, '1000000000000000000000000')
        await wsklima.approve(diamond, '1000000000000000000000000')
        await bct.approve(diamond, '1000000000000000000000000')
        await nct.approve(diamond, '1000000000000000000000000')

        userAddress = signer.address
        defaultEntity = 'KlimaDAO Retirement Aggregator'
        defaultCarbonRetireAmount = BigInt('100000000000')
        bctDefaultProjectAddress = '0xb139C4cC9D20A3618E9a2268D73Eff18C496B991'
        nctDefaultProjectAddress = '0x463de2a5c6E8Bb0c87F4Aa80a02689e6680F72C7'
        bctSpecificProjectAddress = '0x35B73A62Dd351030eCBd4252135e59bbb6345a60'
        nctSpecificProjectAddress = '0x04943C19896c776c78770429eC02C5384ee78292'

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
            describe('Retire BCT', async () => {
                describe('Using BCT', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 4'
                        message = 'Message 4'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(BCT, BCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(BCT, BCT, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await bct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, BCT, bctDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using USDC', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 5'
                        message = 'Message 5'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(USDC, BCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(USDC, BCT, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await usdc.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await bct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, BCT, bctDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using WMATIC', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 5'
                        message = 'Message 5'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(WMATIC, BCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(WMATIC, BCT, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await wmatic.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await bct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, BCT, bctDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using KLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 6'
                        message = 'Message 6'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(KLIMA, BCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(KLIMA, BCT, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await bct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, BCT, bctDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using sKLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 9'
                        message = 'Message 9'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(SKLIMA, BCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(SKLIMA, BCT, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await bct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, BCT, bctDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using wsKLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 10'
                        message = 'Message 10'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(WSKLIMA, BCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(WSKLIMA, BCT, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await wsklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await bct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, BCT, bctDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
            })
            describe('Retire NCT', async () => {
                describe('Using NCT', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 4'
                        message = 'Message 4'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(NCT, NCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(NCT, NCT, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await nct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, NCT, nctDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using USDC', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 5'
                        message = 'Message 5'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(USDC, NCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(USDC, NCT, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await usdc.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await nct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, NCT, nctDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using KLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 6'
                        message = 'Message 6'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(KLIMA, NCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(KLIMA, NCT, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await nct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, NCT, nctDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using sKLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 9'
                        message = 'Message 9'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(SKLIMA, NCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(SKLIMA, NCT, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await nct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, NCT, nctDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using wsKLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 10'
                        message = 'Message 10'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(WSKLIMA, NCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(WSKLIMA, NCT, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await wsklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await nct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, NCT, nctDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
            })
        })
        describe('Specific Retirements', async function () {
            describe('Retire BCT', async () => {
                describe('Using BCT', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 4'
                        message = 'Message 4'
                        sourceAmount = await quoter.getSourceAmountSpecificRetirement(BCT, BCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonSpecific(BCT, BCT, bctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await bct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, BCT, bctSpecificProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using USDC', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 5'
                        message = 'Message 5'
                        sourceAmount = await quoter.getSourceAmountSpecificRetirement(USDC, BCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonSpecific(USDC, BCT, bctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await usdc.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await bct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, BCT, bctSpecificProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using KLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 6'
                        message = 'Message 6'
                        sourceAmount = await quoter.getSourceAmountSpecificRetirement(KLIMA, BCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonSpecific(KLIMA, BCT, bctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await bct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, BCT, bctSpecificProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using sKLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 9'
                        message = 'Message 9'
                        sourceAmount = await quoter.getSourceAmountSpecificRetirement(SKLIMA, BCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonSpecific(SKLIMA, BCT, bctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await bct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, BCT, bctSpecificProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using wsKLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 10'
                        message = 'Message 10'
                        sourceAmount = await quoter.getSourceAmountSpecificRetirement(WSKLIMA, BCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonSpecific(WSKLIMA, BCT, bctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await wsklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await bct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, BCT, bctSpecificProjectAddress, defaultCarbonRetireAmount);
                    })
                })
            })
            describe('Retire NCT', async () => {
                describe('Using NCT', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 4'
                        message = 'Message 4'
                        sourceAmount = await quoter.getSourceAmountSpecificRetirement(NCT, NCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonSpecific(NCT, NCT, nctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await nct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, NCT, nctSpecificProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using USDC', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 5'
                        message = 'Message 5'
                        sourceAmount = await quoter.getSourceAmountSpecificRetirement(USDC, NCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonSpecific(USDC, NCT, nctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await usdc.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await nct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, NCT, nctSpecificProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using KLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 6'
                        message = 'Message 6'
                        sourceAmount = await quoter.getSourceAmountSpecificRetirement(KLIMA, NCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonSpecific(KLIMA, NCT, nctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await nct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, NCT, nctSpecificProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using sKLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 9'
                        message = 'Message 9'
                        sourceAmount = await quoter.getSourceAmountSpecificRetirement(SKLIMA, NCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonSpecific(SKLIMA, NCT, nctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await nct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, NCT, nctSpecificProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using wsKLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 10'
                        message = 'Message 10'
                        sourceAmount = await quoter.getSourceAmountSpecificRetirement(WSKLIMA, NCT, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonSpecific(WSKLIMA, NCT, nctSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await wsklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await nct.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(TOUCAN, signer.address, defaultEntity, userAddress, beneficiary, message, NCT, nctSpecificProjectAddress, defaultCarbonRetireAmount);
                    })
                })
            })
        })
    })
    describe('External Exact Source Retirements', async function () {
        describe('Default Retirements', async function () {
            describe('Retire BCT', async () => {
                describe('Using BCT', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 4'
                        message = 'Message 4'
                        this.result = await retireSourceFacet.retireExactSourceDefault(BCT, BCT, 1000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await bct.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceDefault(USDC, BCT, 1000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await usdc.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await bct.balanceOf(retireSourceFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).gt(currentTotalCarbon)
                    })
                })
                describe('Using WMATIC', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 5'
                        message = 'Message 5'
                        this.result = await retireSourceFacet.retireExactSourceDefault(WMATIC, BCT, '200000000000000000', defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await wmatic.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await bct.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceDefault(KLIMA, BCT, 1000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await bct.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceDefault(SKLIMA, BCT, 1000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await bct.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceDefault(WSKLIMA, BCT, 1000000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await wsklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await bct.balanceOf(retireSourceFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).gt(currentTotalCarbon)
                    })
                })
            })
            describe('Retire NCT', async () => {
                describe('Using NCT', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 4'
                        message = 'Message 4'
                        this.result = await retireSourceFacet.retireExactSourceDefault(NCT, NCT, 1000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await nct.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceDefault(USDC, NCT, 1000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await usdc.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await nct.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceDefault(KLIMA, NCT, 1000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await nct.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceDefault(SKLIMA, NCT, 1000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await nct.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceDefault(WSKLIMA, NCT, 1000000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await wsklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await nct.balanceOf(retireSourceFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).gt(currentTotalCarbon)
                    })
                })
            })
        })

        describe('Specific Retirements', async function () {
            describe('Retire BCT', async () => {
                describe('Using BCT', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 4'
                        message = 'Message 4'
                        this.result = await retireSourceFacet.retireExactSourceSpecific(BCT, BCT, bctSpecificProjectAddress, 1000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await bct.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceSpecific(USDC, BCT, bctSpecificProjectAddress, 1000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await usdc.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await bct.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceSpecific(KLIMA, BCT, bctSpecificProjectAddress, 1000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await bct.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceSpecific(SKLIMA, BCT, bctSpecificProjectAddress, 1000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await bct.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceSpecific(WSKLIMA, BCT, bctSpecificProjectAddress, 1000000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await wsklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await bct.balanceOf(retireSourceFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).gt(currentTotalCarbon)
                    })
                })
            })
            describe('Retire NCT', async () => {
                describe('Using NCT', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 4'
                        message = 'Message 4'
                        this.result = await retireSourceFacet.retireExactSourceSpecific(NCT, NCT, nctSpecificProjectAddress, 1000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await nct.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceSpecific(USDC, NCT, nctSpecificProjectAddress, 1000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await usdc.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await nct.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceSpecific(KLIMA, NCT, nctSpecificProjectAddress, 1000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await nct.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceSpecific(SKLIMA, NCT, nctSpecificProjectAddress, 1000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await nct.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceSpecific(WSKLIMA, NCT, nctSpecificProjectAddress, 1000000000, defaultEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await wsklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await nct.balanceOf(retireSourceFacet.address)).equals(0)
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
