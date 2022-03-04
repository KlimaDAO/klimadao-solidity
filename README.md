# KlimaDAO contracts

## Local Development

```
npm i
npx hardhat compile
```

_NOTE: if you would like to to start a containerized development environment, run `docker-compose up` prior to the previous commands._

## Deploy

Deploy the Klima tokens (KLIMA, sKLIMA, wsKLIMA).
```
npx hardhat run --network <network_name> ./scripts/deploy_KLIMA_Tokens.js
```

Update `.env` with the KLIMA address from the previous step and with the BCT
address and deploy the Klima treasury.
```
npx hardhat run --network <network_name> ./scripts/deploy_KLIMA_treasury.js
```
Note that sKLIMA is not set at the treasury contract and needs to be a separate
transaction to add it as it stands.

Update `.env` with the sKLIMA address from the first step and the treasury
address from the previous step. Also, configure the desired parameters for
the first epoch number, block, and epoch length in the deploy script below.
```
npx hardhat run --network <network_name> ./scripts/deploy_KLIMA_staking.js
```

## Deprecated Contracts

Note that the `AlphaKlimaRedeemUpgradeable` will fail to get built by default, and therefore has been marked deprecated.

In order to compile this contract, you will need to manually update the `@openzeppelin/contracts-upgradeable`
contracts that are downloaded in your `node_modules` by changing `_trustedForwarder`
in `metatx/ERC2771ContextUpgradeable.sol` from a private to a public address.

There is another issue related to the `_trustedForwarder` in that contract that has not yet been resolved.

Since `aKLIMA` was a prelaunch coupon and the existing deployed versino of the redemption contract works as expected, this contract is no longer needed.
