# KlimaDAO contracts

## Build

Note that the `AlphaKlimaRedeemUpgradeable` will fail to get built by default.
You will need to manually update the `@openzeppelin/contracts-upgradeable`
contracts that are downloaded in your `node_modules` by changing `_trustedForwarder`
in `metatx/ERC2771ContextUpgradeable.sol` from a private to a public address.
```
npm i
npx hardhat compile
```

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
