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
foundryup -i v0.3.0 
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

- Deploy the base Diamond, facet implementations, and perform the diamond cut with the following script.
  ```
  forge script script/deployInfinity.s.sol:DeployInfinityScript --fork-url http://localhost:8545 --broadcast --ffi
  ```

## Deprecated Contracts

Note that the `AlphaKlimaRedeemUpgradeable` will fail to build by default, and therefore has been marked deprecated.

In order to compile this contract, you will need to manually update the `@openzeppelin/contracts-upgradeable`
contracts that are downloaded in your `node_modules` by changing `_trustedForwarder`
in `metatx/ERC2771ContextUpgradeable.sol` from a private to a public address.

There is another issue related to the `_trustedForwarder` in that contract that has not yet been resolved.

Since `aKLIMA` was a prelaunch coupon and the existing deployed version of the redemption contract works as expected, this contract is no longer needed.

## Documentation

This repo is configured with [Foundry](https://book.getfoundry.sh/) to generate documentation for the solidity source files with the [forge doc](https://book.getfoundry.sh/reference/forge/forge-doc) command.

Foundry `forge doc` generates and builds an mdbook from the natspec comments contained within the Solidity source files.The `book.toml` file located in the root folder contains the config settings and the `preprocess_summary.py` script allows you to customize the book after it is generated.

The `preprocess_summary.py` script is necessary to customize the book *after Foundry has generated the book from the natspec comments.* This script can also be used to insert additional pages into the book automatically. *If you were to modify the book without this script, each time someone ran the build command it will overwrite these changes.*

*If you have not installed Foundry, follow the guide above before proceeding.*

**Please follow these rules:**
- Annotate your code with [proper NatSpec comments](https://docs.soliditylang.org/en/latest/natspec-format.html)
- Before committing code, run the `forge doc --build` in order to build the doc/book
- A new mdbook should be manually deployed to the public documentation from the `main` branch each time contracts are verified to block explorers like Polygonscan.

You can run a local version of the documentation by running `forge doc --serve`

Vercel is configured to deploy previews of the mdbook from `docs/book`.

### Additional information 

Automating the building and deployment of the solidity documentation mdbook can also be achieved in a number of ways, each with their own trade offs.
1. Configure github actions to checkout foundry toolchain, build the book, and deploy to github pages. This requires a higher tier github org for multiple pages.
2. Configure github actions to checkout foundry toolchain, build the book, and deploy it to Vercel via Vercel CLI. This requires Vercel secrets stored in the repo.
3. Configure github actions to checkout foundry toolchain, build the book, and then commit it to the repo and configure Vercel to deploy. This requires Github actions to add commits after each commit.

*Note: Vercel lacks a system level dependency required to install foundry to build the book before deploying*

Ultimately, it was simpler to document the build process and deploy the public documentation manually as new smart contracts are not deployed frequently enough to warrant automated deployment. These notes were documented in case automatic deployment were to be revisited in the future.