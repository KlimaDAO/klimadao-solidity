/* global describe it before ethers */

const { EXTERNAL, INTERNAL, INTERNAL_EXTERNAL, INTERNAL_TOLERANT } = require('./utils/balances')

const { takeSnapshot, revertToSnapshot } = require("./utils/snapshot");

const { deployDiamond } = require('../scripts/deploy.js')

const { assert, expect } = require('chai');
const { ethers } = require('hardhat');
const { USDC, UBO, NBO, KLIMA, SKLIMA, WSKLIMA, KLIMA_CARBON_RETIREMENTS } = require('./utils/constants.js');
const { C3 } = require('./utils/bridges.js');

describe('C3 Functions', async function () {

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
        klima = await ethers.getContractAt(abi, KLIMA, signer)
        sklima = await ethers.getContractAt(abi, SKLIMA, signer)
        wsklima = await ethers.getContractAt(abi, WSKLIMA, signer)
        ubo = await ethers.getContractAt(abi, UBO, signer)
        nbo = await ethers.getContractAt(abi, NBO, signer)

        await usdc.approve(diamond, '1000000000000000000000000')
        await klima.approve(diamond, '1000000000000000000000000')
        await sklima.approve(diamond, '1000000000000000000000000')
        await wsklima.approve(diamond, '1000000000000000000000000')
        await ubo.approve(diamond, '1000000000000000000000000')
        await nbo.approve(diamond, '1000000000000000000000000')

        userAddress = signer.address
        defaultEntity = 'KlimaDAO Retirement Aggregator'
        customEntity = 'The Best Carbon Desk Ever'
        defaultCarbonRetireAmount = BigInt('1000000000000000')
        uboDefaultProjectAddress = '0xD6Ed6fAE5b6535CAE8d92f40f5FF653dB807A4EA'
        nboDefaultProjectAddress = '0xb6eA7a53FC048D6d3B80b968D696E39482B7e578'
        uboSpecificProjectAddress = '0xD6Ed6fAE5b6535CAE8d92f40f5FF653dB807A4EA'
        nboSpecificProjectAddress = '0xD28DFEBa8fB9e44B715156162C8b6076d7a95Ad1'

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
            describe('Retire UBO', async () => {
                describe('Using UBO', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 4'
                        message = 'Message 4'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(UBO, UBO, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(UBO, UBO, sourceAmount, defaultCarbonRetireAmount, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await ubo.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(C3, signer.address, customEntity, userAddress, beneficiary, message, UBO, uboDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using USDC', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 5'
                        message = 'Message 5'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(USDC, UBO, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(USDC, UBO, sourceAmount, defaultCarbonRetireAmount, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await usdc.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await ubo.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(C3, signer.address, customEntity, userAddress, beneficiary, message, UBO, uboDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using KLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 6'
                        message = 'Message 6'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(KLIMA, UBO, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(KLIMA, UBO, sourceAmount, defaultCarbonRetireAmount, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await ubo.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(C3, signer.address, customEntity, userAddress, beneficiary, message, UBO, uboDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using sKLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 9'
                        message = 'Message 9'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(SKLIMA, UBO, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(SKLIMA, UBO, sourceAmount, defaultCarbonRetireAmount, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await ubo.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(C3, signer.address, customEntity, userAddress, beneficiary, message, UBO, uboDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using wsKLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 10'
                        message = 'Message 10'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(WSKLIMA, UBO, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(WSKLIMA, UBO, sourceAmount, defaultCarbonRetireAmount, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await wsklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await ubo.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(C3, signer.address, customEntity, userAddress, beneficiary, message, UBO, uboDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
            })
            describe('Retire NBO', async () => {
                describe('Using NBO', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 4'
                        message = 'Message 4'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(NBO, NBO, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(NBO, NBO, sourceAmount, defaultCarbonRetireAmount, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await nbo.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(C3, signer.address, customEntity, userAddress, beneficiary, message, NBO, nboDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using USDC', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 5'
                        message = 'Message 5'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(USDC, NBO, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(USDC, NBO, sourceAmount, defaultCarbonRetireAmount, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await usdc.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await nbo.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(C3, signer.address, customEntity, userAddress, beneficiary, message, NBO, nboDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using KLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 6'
                        message = 'Message 6'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(KLIMA, NBO, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(KLIMA, NBO, sourceAmount, defaultCarbonRetireAmount, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await nbo.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(C3, signer.address, customEntity, userAddress, beneficiary, message, NBO, nboDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using sKLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 9'
                        message = 'Message 9'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(SKLIMA, NBO, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(SKLIMA, NBO, sourceAmount, defaultCarbonRetireAmount, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await nbo.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(C3, signer.address, customEntity, userAddress, beneficiary, message, NBO, nboDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using wsKLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 10'
                        message = 'Message 10'
                        sourceAmount = await quoter.getSourceAmountDefaultRetirement(WSKLIMA, NBO, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonDefault(WSKLIMA, NBO, sourceAmount, defaultCarbonRetireAmount, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await wsklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await nbo.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(C3, signer.address, customEntity, userAddress, beneficiary, message, NBO, nboDefaultProjectAddress, defaultCarbonRetireAmount);
                    })
                })
            })
        })

        describe('Specific Retirements', async function () {
            describe('Retire UBO', async () => {
                describe('Using UBO', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 4'
                        message = 'Message 4'
                        sourceAmount = await quoter.getSourceAmountSpecificRetirement(UBO, UBO, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonSpecific(UBO, UBO, uboSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await ubo.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(C3, signer.address, customEntity, userAddress, beneficiary, message, UBO, uboSpecificProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using USDC', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 5'
                        message = 'Message 5'
                        sourceAmount = await quoter.getSourceAmountSpecificRetirement(USDC, UBO, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonSpecific(USDC, UBO, uboSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await usdc.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await ubo.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(C3, signer.address, customEntity, userAddress, beneficiary, message, UBO, uboSpecificProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using KLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 6'
                        message = 'Message 6'
                        sourceAmount = await quoter.getSourceAmountSpecificRetirement(KLIMA, UBO, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonSpecific(KLIMA, UBO, uboSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await ubo.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(C3, signer.address, customEntity, userAddress, beneficiary, message, UBO, uboSpecificProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using sKLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 9'
                        message = 'Message 9'
                        sourceAmount = await quoter.getSourceAmountSpecificRetirement(SKLIMA, UBO, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonSpecific(SKLIMA, UBO, uboSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await ubo.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(C3, signer.address, customEntity, userAddress, beneficiary, message, UBO, uboSpecificProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using wsKLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 10'
                        message = 'Message 10'
                        sourceAmount = await quoter.getSourceAmountSpecificRetirement(WSKLIMA, UBO, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonSpecific(WSKLIMA, UBO, uboSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await wsklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await ubo.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(C3, signer.address, customEntity, userAddress, beneficiary, message, UBO, uboSpecificProjectAddress, defaultCarbonRetireAmount);
                    })
                })
            })
            describe('Retire NBO', async () => {
                describe('Using NBO', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 4'
                        message = 'Message 4'
                        sourceAmount = await quoter.getSourceAmountSpecificRetirement(NBO, NBO, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonSpecific(NBO, NBO, nboSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await nbo.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(C3, signer.address, customEntity, userAddress, beneficiary, message, NBO, nboSpecificProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using USDC', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 5'
                        message = 'Message 5'
                        sourceAmount = await quoter.getSourceAmountSpecificRetirement(USDC, NBO, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonSpecific(USDC, NBO, nboSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await usdc.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await nbo.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(C3, signer.address, customEntity, userAddress, beneficiary, message, NBO, nboSpecificProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using KLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 6'
                        message = 'Message 6'
                        sourceAmount = await quoter.getSourceAmountSpecificRetirement(KLIMA, NBO, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonSpecific(KLIMA, NBO, nboSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await nbo.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(C3, signer.address, customEntity, userAddress, beneficiary, message, NBO, nboSpecificProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using sKLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 9'
                        message = 'Message 9'
                        sourceAmount = await quoter.getSourceAmountSpecificRetirement(SKLIMA, NBO, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonSpecific(SKLIMA, NBO, nboSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await nbo.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(C3, signer.address, customEntity, userAddress, beneficiary, message, NBO, nboSpecificProjectAddress, defaultCarbonRetireAmount);
                    })
                })
                describe('Using wsKLIMA', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 10'
                        message = 'Message 10'
                        sourceAmount = await quoter.getSourceAmountSpecificRetirement(WSKLIMA, NBO, defaultCarbonRetireAmount)
                        this.result = await retireCarbonFacet.retireExactCarbonSpecific(WSKLIMA, NBO, nboSpecificProjectAddress, sourceAmount, defaultCarbonRetireAmount, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await wsklima.balanceOf(retireCarbonFacet.address)).equals(0)
                        expect(await nbo.balanceOf(retireCarbonFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
                    })
                    it('Emits CarbonRetired event', async () => {
                        await expect(this.result).to.emit(retireCarbonFacet, 'CarbonRetired').withArgs(C3, signer.address, customEntity, userAddress, beneficiary, message, NBO, nboSpecificProjectAddress, defaultCarbonRetireAmount);
                    })
                })
            })
        })
    })
    describe('External Exact Source Retirements', async function () {
        describe('Default Retirements', async function () {
            describe('Retire UBO', async () => {
                describe('Using UBO', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 4'
                        message = 'Message 4'
                        this.result = await retireSourceFacet.retireExactSourceDefault(UBO, UBO, 1000000, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await ubo.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceDefault(USDC, UBO, 1000000, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await usdc.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await ubo.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceDefault(KLIMA, UBO, 1000000, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await ubo.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceDefault(SKLIMA, UBO, 1000000, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await ubo.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceDefault(WSKLIMA, UBO, 1000000000, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await wsklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await ubo.balanceOf(retireSourceFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).gt(currentTotalCarbon)
                    })
                })
            })
            describe('Retire NBO', async () => {
                describe('Using NBO', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 4'
                        message = 'Message 4'
                        this.result = await retireSourceFacet.retireExactSourceDefault(NBO, NBO, 1000000, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await nbo.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceDefault(USDC, NBO, 1000000, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await usdc.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await nbo.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceDefault(KLIMA, NBO, 1000000, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await nbo.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceDefault(SKLIMA, NBO, 1000000, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await nbo.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceDefault(WSKLIMA, NBO, 1000000000, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await wsklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await nbo.balanceOf(retireSourceFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).gt(currentTotalCarbon)
                    })
                })
            })
        })

        describe('Specific Retirements', async function () {
            describe('Retire UBO', async () => {
                describe('Using UBO', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 4'
                        message = 'Message 4'
                        this.result = await retireSourceFacet.retireExactSourceSpecific(UBO, UBO, uboSpecificProjectAddress, 1000000, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await ubo.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceSpecific(USDC, UBO, uboSpecificProjectAddress, 1000000, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await usdc.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await ubo.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceSpecific(KLIMA, UBO, uboSpecificProjectAddress, 1000000, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await ubo.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceSpecific(SKLIMA, UBO, uboSpecificProjectAddress, 1000000, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await ubo.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceSpecific(WSKLIMA, UBO, uboSpecificProjectAddress, 1000000000, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await wsklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await ubo.balanceOf(retireSourceFacet.address)).equals(0)
                    })
                    it('Account state values updated', async () => {
                        expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                        expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).gt(currentTotalCarbon)
                    })
                })
            })
            describe('Retire NBO', async () => {
                describe('Using NBO', async () => {
                    beforeEach(async () => {
                        beneficiary = 'Test 4'
                        message = 'Message 4'
                        this.result = await retireSourceFacet.retireExactSourceSpecific(NBO, NBO, nboSpecificProjectAddress, 1000000, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await nbo.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceSpecific(USDC, NBO, nboSpecificProjectAddress, 1000000, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await usdc.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await nbo.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceSpecific(KLIMA, NBO, nboSpecificProjectAddress, 1000000, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await nbo.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceSpecific(SKLIMA, NBO, nboSpecificProjectAddress, 1000000, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await nbo.balanceOf(retireSourceFacet.address)).equals(0)
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
                        this.result = await retireSourceFacet.retireExactSourceSpecific(WSKLIMA, NBO, nboSpecificProjectAddress, 1000000000, customEntity, userAddress, beneficiary, message, EXTERNAL)
                    })
                    it('No tokens left in contract', async () => {
                        expect(await klima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await sklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await wsklima.balanceOf(retireSourceFacet.address)).equals(0)
                        expect(await nbo.balanceOf(retireSourceFacet.address)).equals(0)
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
