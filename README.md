# KlimaDAO contracts

## Local Development

Install foundry:

https://book.getfoundry.sh/getting-started/installation

For Linux and MacOS users:

```
curl -L https://foundry.paradigm.xyz | bash
```

This will download foundryup. Then install Foundry by running:

```
foundryup
```

## Deploy

These examples use a localhost fork running on the `anvil` command

### Base Protocol Contracts

- Deploy the Klima tokens (KLIMA, sKLIMA, wsKLIMA).

  ```
  forge script script/deployProtocolTokens.s.sol:DeployKlimaProtocolTokens --fork-url http://localhost:8545 --broadcast --ffi
  ```

- Update `.env` with the KLIMA and sKLIMA addresses from the previous step and deploy the Klima treasury.

  ```
  forge script script/deployProtocolTreasury.s.sol:DeployKlimaTreasury --fork-url http://localhost:8545 --broadcast --ffi
  ```

- Update `.env` with the treasury address from the previous step. Also, configure the desired parameters for the first epoch number, block, and epoch length in the deploy script below.

  ```
  forge script script/deployProtocolStaking.s.sol:DeployKlimaStaking --fork-url http://localhost:8545 --broadcast --ffi
  ```

### Infinity Diamond Deployment

- Deploy the base Diamond, facet implementations, and perform the diamon cut with the following script.
  ```
  forge script script/deployInfinity.s.sol:DeployInfinityScript --fork-url http://localhost:8545 --broadcast --ffi
  ```

## Deprecated Contracts

Note that the `AlphaKlimaRedeemUpgradeable` will fail to get built by default, and therefore has been marked deprecated.

In order to compile this contract, you will need to manually update the `@openzeppelin/contracts-upgradeable`
contracts that are downloaded in your `node_modules` by changing `_trustedForwarder`
in `metatx/ERC2771ContextUpgradeable.sol` from a private to a public address.

There is another issue related to the `_trustedForwarder` in that contract that has not yet been resolved.

Since `aKLIMA` was a prelaunch coupon and the existing deployed versino of the redemption contract works as expected, this contract is no longer needed.
