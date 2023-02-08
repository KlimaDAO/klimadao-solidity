/* global describe it before ethers */

const { EXTERNAL, INTERNAL, INTERNAL_EXTERNAL, INTERNAL_TOLERANT } = require('./utils/balances')

const { takeSnapshot, revertToSnapshot } = require("./utils/snapshot");

const { deployDiamond } = require('../scripts/deploy.js')

const { expect } = require('chai');
const { ethers } = require('hardhat');
const { UBO, NBO, KLIMA_CARBON_RETIREMENTS, USDC, KLIMA, SKLIMA, WSKLIMA } = require('./utils/constants.js');

describe('C3 Redeem Functions', async function () {

    before(async function () {
        diamond = await deployDiamond()
        redeemFacet = await ethers.getContractAt('RedeemC3PoolFacet', diamond)
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
            describe('Using UBO', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountDefaultRedeem(UBO, UBO, defaultCarbonRetireAmount)

                    this.result = await redeemFacet.c3RedeemPoolDefault(
                        UBO,
                        UBO,
                        defaultCarbonRetireAmount,
                        sourceAmount,
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
                    expect(await tco2.balanceOf(signer.address)).greaterThanOrEqual(defaultCarbonRetireAmount)
                })
            })
            describe('Using USDC', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountDefaultRedeem(USDC, UBO, defaultCarbonRetireAmount)

                    this.result = await redeemFacet.c3RedeemPoolDefault(
                        USDC,
                        UBO,
                        defaultCarbonRetireAmount,
                        sourceAmount,
                        EXTERNAL,
                        EXTERNAL)
                })
                it('No tokens left in contract', async () => {
                    tco2 = await ethers.getContractAt(abi, uboDefaultProjectAddress, signer)
                    expect(await usdc.balanceOf(redeemFacet.address)).equals(0)
                    expect(await tco2.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, uboDefaultProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).greaterThanOrEqual(defaultCarbonRetireAmount)
                })
            })
            describe('Using KLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountDefaultRedeem(KLIMA, UBO, defaultCarbonRetireAmount)

                    this.result = await redeemFacet.c3RedeemPoolDefault(
                        KLIMA,
                        UBO,
                        defaultCarbonRetireAmount,
                        sourceAmount,
                        EXTERNAL,
                        EXTERNAL)
                })
                it('No tokens left in contract', async () => {
                    tco2 = await ethers.getContractAt(abi, uboDefaultProjectAddress, signer)
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await tco2.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, uboDefaultProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).greaterThanOrEqual(defaultCarbonRetireAmount)
                })
            })
            describe('Using sKLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountDefaultRedeem(SKLIMA, UBO, defaultCarbonRetireAmount)

                    this.result = await redeemFacet.c3RedeemPoolDefault(
                        SKLIMA,
                        UBO,
                        defaultCarbonRetireAmount,
                        sourceAmount,
                        EXTERNAL,
                        EXTERNAL)
                })
                it('No tokens left in contract', async () => {
                    tco2 = await ethers.getContractAt(abi, uboDefaultProjectAddress, signer)
                    expect(await sklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await tco2.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, uboDefaultProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).greaterThanOrEqual(defaultCarbonRetireAmount)
                })
            })
            describe('Using wsKLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountDefaultRedeem(WSKLIMA, UBO, defaultCarbonRetireAmount)

                    this.result = await redeemFacet.c3RedeemPoolDefault(
                        WSKLIMA,
                        UBO,
                        defaultCarbonRetireAmount,
                        sourceAmount,
                        EXTERNAL,
                        EXTERNAL)
                })
                it('No tokens left in contract', async () => {
                    tco2 = await ethers.getContractAt(abi, uboDefaultProjectAddress, signer)
                    expect(await wsklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await sklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await tco2.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, uboDefaultProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).greaterThanOrEqual(defaultCarbonRetireAmount)
                })
            })
        })
        describe('Redeem NBO', async () => {
            describe('Using NBO', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountDefaultRedeem(NBO, NBO, defaultCarbonRetireAmount)

                    this.result = await redeemFacet.c3RedeemPoolDefault(
                        NBO,
                        NBO,
                        defaultCarbonRetireAmount,
                        sourceAmount,
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
                    expect(await tco2.balanceOf(signer.address)).greaterThanOrEqual(defaultCarbonRetireAmount)
                })
            })
            describe('Using USDC', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountDefaultRedeem(USDC, NBO, defaultCarbonRetireAmount)

                    this.result = await redeemFacet.c3RedeemPoolDefault(
                        USDC,
                        NBO,
                        defaultCarbonRetireAmount,
                        sourceAmount,
                        EXTERNAL,
                        EXTERNAL)
                })
                it('No tokens left in contract', async () => {
                    expect(await usdc.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, nboDefaultProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).greaterThanOrEqual(defaultCarbonRetireAmount)
                })
            })
            describe('Using KLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountDefaultRedeem(KLIMA, NBO, defaultCarbonRetireAmount)

                    this.result = await redeemFacet.c3RedeemPoolDefault(
                        KLIMA,
                        NBO,
                        defaultCarbonRetireAmount,
                        sourceAmount,
                        EXTERNAL,
                        EXTERNAL)
                })
                it('No tokens left in contract', async () => {
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, nboDefaultProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).greaterThanOrEqual(defaultCarbonRetireAmount)
                })
            })
            describe('Using sKLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountDefaultRedeem(SKLIMA, NBO, defaultCarbonRetireAmount)

                    this.result = await redeemFacet.c3RedeemPoolDefault(
                        SKLIMA,
                        NBO,
                        defaultCarbonRetireAmount,
                        sourceAmount,
                        EXTERNAL,
                        EXTERNAL)
                })
                it('No tokens left in contract', async () => {
                    expect(await sklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, nboDefaultProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).greaterThanOrEqual(defaultCarbonRetireAmount)
                })
            })
            describe('Using wsKLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountDefaultRedeem(WSKLIMA, NBO, defaultCarbonRetireAmount)

                    this.result = await redeemFacet.c3RedeemPoolDefault(
                        WSKLIMA,
                        NBO,
                        defaultCarbonRetireAmount,
                        sourceAmount,
                        EXTERNAL,
                        EXTERNAL)
                })
                it('No tokens left in contract', async () => {
                    expect(await wsklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await sklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, nboDefaultProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).greaterThanOrEqual(defaultCarbonRetireAmount)
                })
            })
        })
    })
    describe('External Specific Redemptions', async function () {
        describe('Redeem UBO', async () => {
            describe('Using UBO', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountSpecificRedeem(UBO, UBO, [ethers.BigNumber.from(defaultCarbonRetireAmount)])

                    this.result = await redeemFacet.c3RedeemPoolSpecific(
                        UBO,
                        UBO,
                        sourceAmount,
                        [uboSpecificProjectAddress],
                        [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                        EXTERNAL,
                        EXTERNAL
                    )
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
                    expect(await tco2.balanceOf(signer.address)).greaterThanOrEqual(defaultCarbonRetireAmount)
                })
            })
            describe('Using USDC', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountSpecificRedeem(USDC, UBO, [ethers.BigNumber.from(defaultCarbonRetireAmount)])

                    this.result = await redeemFacet.c3RedeemPoolSpecific(
                        USDC,
                        UBO,
                        sourceAmount,
                        [uboSpecificProjectAddress],
                        [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                        EXTERNAL,
                        EXTERNAL
                    )
                })
                it('No tokens left in contract', async () => {
                    expect(await usdc.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, uboSpecificProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).greaterThanOrEqual(defaultCarbonRetireAmount)
                })
            })
            describe('Using KLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountSpecificRedeem(KLIMA, UBO, [ethers.BigNumber.from(defaultCarbonRetireAmount)])

                    this.result = await redeemFacet.c3RedeemPoolSpecific(
                        KLIMA,
                        UBO,
                        sourceAmount,
                        [uboSpecificProjectAddress],
                        [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                        EXTERNAL,
                        EXTERNAL
                    )
                })
                it('No tokens left in contract', async () => {
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, uboSpecificProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).greaterThanOrEqual(defaultCarbonRetireAmount)
                })
            })
            describe('Using sKLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountSpecificRedeem(SKLIMA, UBO, [ethers.BigNumber.from(defaultCarbonRetireAmount)])

                    this.result = await redeemFacet.c3RedeemPoolSpecific(
                        SKLIMA,
                        UBO,
                        sourceAmount,
                        [uboSpecificProjectAddress],
                        [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                        EXTERNAL,
                        EXTERNAL
                    )
                })
                it('No tokens left in contract', async () => {
                    expect(await sklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, uboSpecificProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).greaterThanOrEqual(defaultCarbonRetireAmount)
                })
            })
            describe('Using wsKLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountSpecificRedeem(WSKLIMA, UBO, [ethers.BigNumber.from(defaultCarbonRetireAmount)])

                    this.result = await redeemFacet.c3RedeemPoolSpecific(
                        WSKLIMA,
                        UBO,
                        sourceAmount,
                        [uboSpecificProjectAddress],
                        [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                        EXTERNAL,
                        EXTERNAL
                    )
                })
                it('No tokens left in contract', async () => {
                    expect(await wsklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await sklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, uboSpecificProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).greaterThanOrEqual(defaultCarbonRetireAmount)
                })
            })
        })
        describe('Redeem NBO', async () => {
            describe('Using NBO', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountSpecificRedeem(NBO, NBO, [ethers.BigNumber.from(defaultCarbonRetireAmount)])

                    this.result = await redeemFacet.c3RedeemPoolSpecific(
                        NBO,
                        NBO,
                        sourceAmount,
                        [nboSpecificProjectAddress],
                        [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                        EXTERNAL,
                        EXTERNAL
                    )
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
                    expect(await tco2.balanceOf(signer.address)).greaterThanOrEqual(defaultCarbonRetireAmount)
                })
            })
            describe('Using USDC', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountSpecificRedeem(USDC, NBO, [ethers.BigNumber.from(defaultCarbonRetireAmount)])

                    this.result = await redeemFacet.c3RedeemPoolSpecific(
                        USDC,
                        NBO,
                        sourceAmount,
                        [nboSpecificProjectAddress],
                        [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                        EXTERNAL,
                        EXTERNAL
                    )
                })
                it('No tokens left in contract', async () => {
                    expect(await usdc.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, nboSpecificProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).greaterThanOrEqual(defaultCarbonRetireAmount)
                })
            })
            describe('Using KLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountSpecificRedeem(KLIMA, NBO, [ethers.BigNumber.from(defaultCarbonRetireAmount)])

                    this.result = await redeemFacet.c3RedeemPoolSpecific(
                        KLIMA,
                        NBO,
                        sourceAmount,
                        [nboSpecificProjectAddress],
                        [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                        EXTERNAL,
                        EXTERNAL
                    )
                })
                it('No tokens left in contract', async () => {
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, nboSpecificProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).greaterThanOrEqual(defaultCarbonRetireAmount)
                })
            })
            describe('Using sKLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountSpecificRedeem(SKLIMA, NBO, [ethers.BigNumber.from(defaultCarbonRetireAmount)])

                    this.result = await redeemFacet.c3RedeemPoolSpecific(
                        SKLIMA,
                        NBO,
                        sourceAmount,
                        [nboSpecificProjectAddress],
                        [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                        EXTERNAL,
                        EXTERNAL
                    )
                })
                it('No tokens left in contract', async () => {
                    expect(await sklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, nboSpecificProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).greaterThanOrEqual(defaultCarbonRetireAmount)
                })
            })
            describe('Using wsKLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountSpecificRedeem(WSKLIMA, NBO, [ethers.BigNumber.from(defaultCarbonRetireAmount)])

                    this.result = await redeemFacet.c3RedeemPoolSpecific(
                        WSKLIMA,
                        NBO,
                        sourceAmount,
                        [nboSpecificProjectAddress],
                        [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                        EXTERNAL,
                        EXTERNAL
                    )
                })
                it('No tokens left in contract', async () => {
                    expect(await wsklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await sklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, nboSpecificProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).greaterThanOrEqual(defaultCarbonRetireAmount)
                })
            })
        })
    })
})
