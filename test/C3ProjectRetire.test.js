/* global describe it before ethers */

const { EXTERNAL, INTERNAL, INTERNAL_EXTERNAL, INTERNAL_TOLERANT } = require('./utils/balances')

const { takeSnapshot, revertToSnapshot } = require("./utils/snapshot");

const { deployDiamond } = require('../scripts/deploy.js')

const { assert, expect } = require('chai');
const { ethers } = require('hardhat');
const { USDC, UBO, NBO, KLIMA, SKLIMA, WSKLIMA, ZERO_ADDRESS, KLIMA_CARBON_RETIREMENTS } = require('./utils/constants.js');
const { C3 } = require('./utils/bridges.js');

describe('C3 C3T Functions', async function () {

    before(async function () {
        diamond = await deployDiamond()
        redeemFacet = await ethers.getContractAt('RedeemC3PoolFacet', diamond)
        retireInfoFacet = await ethers.getContractAt('RetireInfoFacet', diamond)
        retireC3C3T = await ethers.getContractAt('RetireC3C3TFacet', diamond)
        tokenFacet = await ethers.getContractAt('TokenFacet', diamond)

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
        defaultCarbonRetireAmount = BigInt('100000000000')
        uboDefaultProjectAddress = '0xD6Ed6fAE5b6535CAE8d92f40f5FF653dB807A4EA'
        nboDefaultProjectAddress = '0xb6eA7a53FC048D6d3B80b968D696E39482B7e578'
        uboSpecificProjectAddress = '0xD6Ed6fAE5b6535CAE8d92f40f5FF653dB807A4EA'
        nboSpecificProjectAddress = '0xD28DFEBa8fB9e44B715156162C8b6076d7a95Ad1'

        tco2 = await ethers.getContractAt(abi, uboDefaultProjectAddress, signer)
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

    describe('External C3T Redemptions', async function () {
        describe('Retire C3T', async () => {
            beforeEach(async () => {
                beneficiary = 'Test 1'
                message = 'Message 1'
                await redeemFacet.c3_redeemPoolDefault(UBO, defaultCarbonRetireAmount, EXTERNAL, EXTERNAL)
                this.result = await retireC3C3T.c3_retireExactC3T(
                    uboDefaultProjectAddress,
                    defaultCarbonRetireAmount,
                    userAddress,
                    beneficiary,
                    message,
                    EXTERNAL
                )
            })
            it('No tokens left in contract', async () => {
                expect(await ubo.balanceOf(retireC3C3T.address)).equals(0)
            })
            it('Account state values updated', async () => {
                expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(expectedRetirements)
                expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(expectedCarbonRetired)
            })
            it('Emits CarbonRetired event', async () => {
                await expect(this.result).to.emit(retireC3C3T, 'CarbonRetired').withArgs(C3, signer.address, defaultEntity, userAddress, beneficiary, message, ZERO_ADDRESS, uboDefaultProjectAddress, defaultCarbonRetireAmount);
            })
        })
    })
})
