/* global describe it before ethers */

const { EXTERNAL, INTERNAL, INTERNAL_EXTERNAL, INTERNAL_TOLERANT } = require('./utils/balances')

const { takeSnapshot, revertToSnapshot } = require("./utils/snapshot");

const { deployDiamond } = require('../scripts/deploy.js')

const { expect } = require('chai');
const { ethers } = require('hardhat');
const { BCT, NCT, KLIMA_CARBON_RETIREMENTS, USDC, KLIMA, SKLIMA, WSKLIMA } = require('./utils/constants.js');

describe('Toucan Redeem Functions', async function () {

    before(async function () {
        diamond = await deployDiamond()
        redeemFacet = await ethers.getContractAt('RedeemToucanPoolFacet', diamond)
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
        bct = await ethers.getContractAt(abi, BCT, signer)
        nct = await ethers.getContractAt(abi, NCT, signer)

        await usdc.approve(diamond, '1000000000000000000000000')
        await klima.approve(diamond, '1000000000000000000000000')
        await sklima.approve(diamond, '1000000000000000000000000')
        await wsklima.approve(diamond, '1000000000000000000000000')
        await bct.approve(diamond, '1000000000000000000000000')
        await nct.approve(diamond, '1000000000000000000000000')

        userAddress = signer.address
        defaultCarbonRetireAmount = '100000000000'
        bctDefaultProjectAddress = '0xb139C4cC9D20A3618E9a2268D73Eff18C496B991'
        nctDefaultProjectAddress = '0x6362364A37F34d39a1f4993fb595dAB4116dAf0d'
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
            describe('Using BCT', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountDefaultRedeem(BCT, BCT, defaultCarbonRetireAmount)

                    this.result = await redeemFacet.toucan_redeemExactCarbonPoolDefault(
                        BCT,
                        BCT,
                        defaultCarbonRetireAmount,
                        sourceAmount,
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
            describe('Using USDC', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountDefaultRedeem(USDC, BCT, defaultCarbonRetireAmount)

                    this.result = await redeemFacet.toucan_redeemExactCarbonPoolDefault(
                        USDC,
                        BCT,
                        defaultCarbonRetireAmount,
                        sourceAmount,
                        EXTERNAL,
                        EXTERNAL)
                })
                it('No tokens left in contract', async () => {
                    expect(await usdc.balanceOf(redeemFacet.address)).equals(0)
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
            describe('Using KLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountDefaultRedeem(KLIMA, BCT, defaultCarbonRetireAmount)

                    this.result = await redeemFacet.toucan_redeemExactCarbonPoolDefault(
                        KLIMA,
                        BCT,
                        defaultCarbonRetireAmount,
                        sourceAmount,
                        EXTERNAL,
                        EXTERNAL)
                })
                it('No tokens left in contract', async () => {
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
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
            describe('Using sKLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountDefaultRedeem(SKLIMA, BCT, defaultCarbonRetireAmount)

                    this.result = await redeemFacet.toucan_redeemExactCarbonPoolDefault(
                        SKLIMA,
                        BCT,
                        defaultCarbonRetireAmount,
                        sourceAmount,
                        EXTERNAL,
                        EXTERNAL)
                })
                it('No tokens left in contract', async () => {
                    expect(await sklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
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
            describe('Using wsKLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountDefaultRedeem(WSKLIMA, BCT, defaultCarbonRetireAmount)

                    this.result = await redeemFacet.toucan_redeemExactCarbonPoolDefault(
                        WSKLIMA,
                        BCT,
                        defaultCarbonRetireAmount,
                        sourceAmount,
                        EXTERNAL,
                        EXTERNAL)
                })
                it('No tokens left in contract', async () => {
                    expect(await wsklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await sklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
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
        })
        describe('Redeem NCT', async () => {
            describe('Using NCT ', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountDefaultRedeem(NCT, NCT, defaultCarbonRetireAmount)

                    this.result = await redeemFacet.toucan_redeemExactCarbonPoolDefault(
                        NCT,
                        NCT,
                        defaultCarbonRetireAmount,
                        sourceAmount,
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
            describe('Using USDC ', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountDefaultRedeem(USDC, NCT, defaultCarbonRetireAmount)

                    this.result = await redeemFacet.toucan_redeemExactCarbonPoolDefault(
                        USDC,
                        NCT,
                        defaultCarbonRetireAmount,
                        sourceAmount,
                        EXTERNAL,
                        EXTERNAL)
                })
                it('No tokens left in contract', async () => {
                    expect(await usdc.balanceOf(redeemFacet.address)).equals(0)
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
            describe('Using KLIMA ', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountDefaultRedeem(KLIMA, NCT, defaultCarbonRetireAmount)

                    this.result = await redeemFacet.toucan_redeemExactCarbonPoolDefault(
                        KLIMA,
                        NCT,
                        defaultCarbonRetireAmount,
                        sourceAmount,
                        EXTERNAL,
                        EXTERNAL)
                })
                it('No tokens left in contract', async () => {
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
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
            describe('Using sKLIMA ', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountDefaultRedeem(SKLIMA, NCT, defaultCarbonRetireAmount)

                    this.result = await redeemFacet.toucan_redeemExactCarbonPoolDefault(
                        SKLIMA,
                        NCT,
                        defaultCarbonRetireAmount,
                        sourceAmount,
                        EXTERNAL,
                        EXTERNAL)
                })
                it('No tokens left in contract', async () => {
                    expect(await sklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
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
            describe('Using wsKLIMA ', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountDefaultRedeem(WSKLIMA, NCT, defaultCarbonRetireAmount)

                    this.result = await redeemFacet.toucan_redeemExactCarbonPoolDefault(
                        WSKLIMA,
                        NCT,
                        defaultCarbonRetireAmount,
                        sourceAmount,
                        EXTERNAL,
                        EXTERNAL)
                })
                it('No tokens left in contract', async () => {
                    expect(await wsklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await sklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
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
    })
    describe('External Specific Redemptions', async function () {
        describe('Redeem BCT', async () => {
            describe('Using BCT', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountSpecificRedeem(BCT, BCT, [ethers.BigNumber.from(defaultCarbonRetireAmount)])

                    this.result = await redeemFacet.toucan_redeemExactCarbonPoolSpecific(
                        BCT,
                        BCT,
                        sourceAmount,
                        [bctSpecificProjectAddress],
                        [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                        EXTERNAL,
                        EXTERNAL
                    )
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
                    expect(await tco2.balanceOf(signer.address)).equals(defaultCarbonRetireAmount)
                })
            })
            describe('Using USDC', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountSpecificRedeem(USDC, BCT, [ethers.BigNumber.from(defaultCarbonRetireAmount)])

                    this.result = await redeemFacet.toucan_redeemExactCarbonPoolSpecific(
                        USDC,
                        BCT,
                        sourceAmount,
                        [bctSpecificProjectAddress],
                        [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                        EXTERNAL,
                        EXTERNAL
                    )
                })
                it('No tokens left in contract', async () => {
                    expect(await usdc.balanceOf(redeemFacet.address)).equals(0)
                    expect(await bct.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, bctSpecificProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).equals(defaultCarbonRetireAmount)
                })
            })
            describe('Using KLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountSpecificRedeem(KLIMA, BCT, [ethers.BigNumber.from(defaultCarbonRetireAmount)])

                    this.result = await redeemFacet.toucan_redeemExactCarbonPoolSpecific(
                        KLIMA,
                        BCT,
                        sourceAmount,
                        [bctSpecificProjectAddress],
                        [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                        EXTERNAL,
                        EXTERNAL
                    )
                })
                it('No tokens left in contract', async () => {
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await bct.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, bctSpecificProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).equals(defaultCarbonRetireAmount)
                })
            })
            describe('Using sKLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountSpecificRedeem(SKLIMA, BCT, [ethers.BigNumber.from(defaultCarbonRetireAmount)])

                    this.result = await redeemFacet.toucan_redeemExactCarbonPoolSpecific(
                        SKLIMA,
                        BCT,
                        sourceAmount,
                        [bctSpecificProjectAddress],
                        [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                        EXTERNAL,
                        EXTERNAL
                    )
                })
                it('No tokens left in contract', async () => {
                    expect(await sklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await bct.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, bctSpecificProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).equals(defaultCarbonRetireAmount)
                })
            })
            describe('Using wsKLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountSpecificRedeem(WSKLIMA, BCT, [ethers.BigNumber.from(defaultCarbonRetireAmount)])

                    this.result = await redeemFacet.toucan_redeemExactCarbonPoolSpecific(
                        WSKLIMA,
                        BCT,
                        sourceAmount,
                        [bctSpecificProjectAddress],
                        [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                        EXTERNAL,
                        EXTERNAL
                    )
                })
                it('No tokens left in contract', async () => {
                    expect(await wsklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await sklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await bct.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, bctSpecificProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).equals(defaultCarbonRetireAmount)
                })
            })
        })
        describe('Redeem NCT', async () => {
            describe('Using NCT', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountSpecificRedeem(NCT, NCT, [ethers.BigNumber.from(defaultCarbonRetireAmount)])

                    this.result = await redeemFacet.toucan_redeemExactCarbonPoolSpecific(
                        NCT,
                        NCT,
                        sourceAmount,
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
                    expect(await tco2.balanceOf(signer.address)).equals(defaultCarbonRetireAmount)
                })
            })
            describe('Using USDC', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountSpecificRedeem(USDC, NCT, [ethers.BigNumber.from(defaultCarbonRetireAmount)])

                    this.result = await redeemFacet.toucan_redeemExactCarbonPoolSpecific(
                        USDC,
                        NCT,
                        sourceAmount,
                        [nctSpecificProjectAddress],
                        [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                        EXTERNAL,
                        EXTERNAL)
                })
                it('No tokens left in contract', async () => {
                    expect(await usdc.balanceOf(redeemFacet.address)).equals(0)
                    expect(await nct.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, nctSpecificProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).equals(defaultCarbonRetireAmount)
                })
            })
            describe('Using KLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountSpecificRedeem(KLIMA, NCT, [ethers.BigNumber.from(defaultCarbonRetireAmount)])

                    this.result = await redeemFacet.toucan_redeemExactCarbonPoolSpecific(
                        KLIMA,
                        NCT,
                        sourceAmount,
                        [nctSpecificProjectAddress],
                        [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                        EXTERNAL,
                        EXTERNAL)
                })
                it('No tokens left in contract', async () => {
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await nct.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, nctSpecificProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).equals(defaultCarbonRetireAmount)
                })
            })
            describe('Using sKLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountSpecificRedeem(SKLIMA, NCT, [ethers.BigNumber.from(defaultCarbonRetireAmount)])

                    this.result = await redeemFacet.toucan_redeemExactCarbonPoolSpecific(
                        SKLIMA,
                        NCT,
                        sourceAmount,
                        [nctSpecificProjectAddress],
                        [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                        EXTERNAL,
                        EXTERNAL)
                })
                it('No tokens left in contract', async () => {
                    expect(await sklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await nct.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, nctSpecificProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).equals(defaultCarbonRetireAmount)
                })
            })
            describe('Using wsKLIMA', async () => {
                beforeEach(async () => {
                    sourceAmount = await quoter.getSourceAmountSpecificRedeem(WSKLIMA, NCT, [ethers.BigNumber.from(defaultCarbonRetireAmount)])

                    this.result = await redeemFacet.toucan_redeemExactCarbonPoolSpecific(
                        WSKLIMA,
                        NCT,
                        sourceAmount,
                        [nctSpecificProjectAddress],
                        [ethers.BigNumber.from(defaultCarbonRetireAmount)],
                        EXTERNAL,
                        EXTERNAL)
                })
                it('No tokens left in contract', async () => {
                    expect(await wsklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await sklima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await klima.balanceOf(redeemFacet.address)).equals(0)
                    expect(await nct.balanceOf(redeemFacet.address)).equals(0)
                })
                it('Account state values updated', async () => {
                    expect(await retireInfoFacet.getTotalRetirements(userAddress)).equals(currentRetirements)
                    expect(await retireInfoFacet.getTotalCarbonRetired(userAddress)).equals(currentTotalCarbon)
                })
                it('Caller has TCO2 tokens', async () => {
                    tco2 = await ethers.getContractAt(abi, nctSpecificProjectAddress, signer)
                    expect(await tco2.balanceOf(signer.address)).equals(defaultCarbonRetireAmount)
                })
            })
        })
    })
})
