# KlimaDAO contracts

## Build

TODO: Document OZ hack that is needed in order to build the contracts
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

Update `.env` with the sKLIMA address from the previous step and with the BCT
address and deploy the Klima staking contracts.
```
npx hardhat run --network <network_name> ./scripts/deploy_KLIMA_staking.js
```