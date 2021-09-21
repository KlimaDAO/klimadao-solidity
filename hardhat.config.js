const { utils } = require("ethers");
const fs = require("fs");
const chalk = require("chalk");

require("@nomiclabs/hardhat-etherscan");
require("@tenderly/hardhat-tenderly");
require("hardhat-deploy");
require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");

require("dotenv").config();

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require("solidity-coverage");

const { isAddress, getAddress, formatUnits, parseUnits } = utils;

const DEBUG = false;

const defaultNetwork = "localhost";

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  networks: {
    hardhat: {
      initialBaseFeePerGas: 0, // workaround from https://github.com/sc-forks/solidity-coverage/issues/652#issuecomment-896330136 . Remove when that issue is closed.
    },
    ropsten: {
      url: process.env.ROPSTEN_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    kovan: {
      url: "https://kovan.infura.io/v3/0f83eb63faea409abc1f440c9f077646", // <---- YOUR INFURA ID! (or it won't work)
      accounts: {
        mnemonic: mnemonic(),
      },
    },
    mainnet: {
      url: "https://mainnet.infura.io/v3/0f83eb63faea409abc1f440c9f077646", // <---- YOUR INFURA ID! (or it won't work)
      accounts: {
        mnemonic: mnemonic(),
      },
    },
    goerli: {
      url: "https://goerli.infura.io/v3/0f83eb63faea409abc1f440c9f077646", // <---- YOUR INFURA ID! (or it won't work)
      accounts: {
        mnemonic: mnemonic(),
      },
    },
    xdai: {
      url: "https://rpc.xdaichain.com/",
      gasPrice: 1000000000,
      accounts: {
        mnemonic: mnemonic(),
      },
    },
    matic: {
      url: "https://polygon-mainnet.infura.io/v3/0f83eb63faea409abc1f440c9f077646",
      gasPrice: 10e9,
      accounts: {
        mnemonic: mnemonic(),
      },
    },
    mumbai: {
      url: "https://polygon-mumbai.infura.io/v3/0f83eb63faea409abc1f440c9f077646",
      gasPrice: 5e9,
      accounts: {
        mnemonic: mnemonic(),
      },
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

// mnemonic.txt.txt used for live deployments
function mnemonic() {
  try {
    return fs.readFileSync('./mnemonic.txt').toString().trim();
  } catch (e) {
    if (defaultNetwork !== 'localhost') {
      console.log(
        '☢️ WARNING: No mnemonic.txt file created for a deploy account. Try `yarn run generate` and then `yarn run account`.'
      );
    }
  }
  return '';
}

function debug(text) {
  if (DEBUG) {
    console.log(text);
  }
}

// -----------------------------------
// ------- HARDHAT TASKS -------------
// -----------------------------------

task('wallet', 'Create a wallet (pk) link', async (_, { ethers }) => {
  const randomWallet = ethers.Wallet.createRandom();
  const privateKey = randomWallet._signingKey().privateKey;
  console.log('🔐 WALLET Generated as ' + randomWallet.address + '');
  console.log('🔗 http://localhost:3000/pk#' + privateKey);
});

task('fundedwallet', 'Create a wallet (pk) link and fund it with deployer?')
  .addOptionalParam(
    'amount',
    'Amount of ETH to send to wallet after generating'
  )
  .addOptionalParam('url', 'URL to add pk to')
  .setAction(async (taskArgs, { network, ethers }) => {
    const randomWallet = ethers.Wallet.createRandom();
    const privateKey = randomWallet._signingKey().privateKey;
    console.log('🔐 WALLET Generated as ' + randomWallet.address + '');
    let url = taskArgs.url ? taskArgs.url : 'http://localhost:3000';

    let localDeployerMnemonic;
    try {
      localDeployerMnemonic = fs.readFileSync('./mnemonic.txt.txt');
      localDeployerMnemonic = localDeployerMnemonic.toString().trim();
    } catch (e) {
      /* do nothing - this file isn't always there */
    }

    let amount = taskArgs.amount ? taskArgs.amount : '0.01';
    const tx = {
      to: randomWallet.address,
      value: ethers.utils.parseEther(amount),
    };

    //SEND USING LOCAL DEPLOYER MNEMONIC IF THERE IS ONE
    // IF NOT SEND USING LOCAL HARDHAT NODE:
    if (localDeployerMnemonic) {
      let deployerWallet = new ethers.Wallet.fromMnemonic(
        localDeployerMnemonic
      );
      deployerWallet = deployerWallet.connect(ethers.provider);
      console.log(
        '💵 Sending ' +
        amount +
        ' ETH to ' +
        randomWallet.address +
        ' using deployer account'
      );
      let sendresult = await deployerWallet.sendTransaction(tx);
      console.log('\n' + url + '/pk#' + privateKey + '\n');
      return;
    } else {
      console.log(
        '💵 Sending ' +
        amount +
        ' ETH to ' +
        randomWallet.address +
        ' using local node'
      );
      console.log('\n' + url + '/pk#' + privateKey + '\n');
      return send(ethers.provider.getSigner(), tx);
    }
  });

task(
  'generate',
  'Create a mnemonic.txt for builder deploys',
  async (_, { ethers }) => {
    const bip39 = require('bip39');
    const hdkey = require('ethereumjs-wallet/hdkey');
    const mnemonic = bip39.generateMnemonic();
    if (DEBUG) console.log('mnemonic', mnemonic);
    const seed = await bip39.mnemonicToSeed(mnemonic);
    if (DEBUG) console.log('seed', seed);
    const hdwallet = hdkey.fromMasterSeed(seed);
    const wallet_hdpath = "m/44'/60'/0'/0/";
    const account_index = 0;
    let fullPath = wallet_hdpath + account_index;
    if (DEBUG) console.log('fullPath', fullPath);
    const wallet = hdwallet.derivePath(fullPath).getWallet();
    const privateKey = '0x' + wallet._privKey.toString('hex');
    if (DEBUG) console.log('privateKey', privateKey);
    var EthUtil = require('ethereumjs-util');
    const address =
      '0x' + EthUtil.privateToAddress(wallet._privKey).toString('hex');
    console.log(
      '🔐 Account Generated as ' +
      address +
      ' and set as mnemonic.txt in packages/hardhat'
    );
    console.log(
      "💬 Use 'yarn run account' to get more information about the deployment account."
    );

    fs.writeFileSync('./' + address + '.txt', mnemonic.toString());
    fs.writeFileSync('./mnemonic.txt.txt', mnemonic.toString());
  }
);

task(
  'mineContractAddress',
  'Looks for a deployer account that will give leading zeros'
)
  .addParam('searchFor', 'String to search for')
  .setAction(async (taskArgs, { network, ethers }) => {
    let contract_address = '';
    let address;

    const bip39 = require('bip39');
    const hdkey = require('ethereumjs-wallet/hdkey');

    let mnemonic = '';
    while (contract_address.indexOf(taskArgs.searchFor) != 0) {
      mnemonic = bip39.generateMnemonic();
      if (DEBUG) console.log('mnemonic', mnemonic);
      const seed = await bip39.mnemonicToSeed(mnemonic);
      if (DEBUG) console.log('seed', seed);
      const hdwallet = hdkey.fromMasterSeed(seed);
      const wallet_hdpath = "m/44'/60'/0'/0/";
      const account_index = 0;
      let fullPath = wallet_hdpath + account_index;
      if (DEBUG) console.log('fullPath', fullPath);
      const wallet = hdwallet.derivePath(fullPath).getWallet();
      const privateKey = '0x' + wallet._privKey.toString('hex');
      if (DEBUG) console.log('privateKey', privateKey);
      var EthUtil = require('ethereumjs-util');
      address =
        '0x' + EthUtil.privateToAddress(wallet._privKey).toString('hex');

      const rlp = require('rlp');
      const keccak = require('keccak');

      let nonce = 0x00; //The nonce must be a hex literal!
      let sender = address;

      let input_arr = [sender, nonce];
      let rlp_encoded = rlp.encode(input_arr);

      let contract_address_long = keccak('keccak256')
        .update(rlp_encoded)
        .digest('hex');

      contract_address = contract_address_long.substring(24); //Trim the first 24 characters.
    }

    console.log(
      '⛏  Account Mined as ' +
      address +
      ' and set as mnemonic.txt in packages/hardhat'
    );
    console.log(
      '📜 This will create the first contract: ' +
      chalk.magenta('0x' + contract_address)
    );
    console.log(
      "💬 Use 'yarn run account' to get more information about the deployment account."
    );

    fs.writeFileSync(
      './' + address + '_produces' + contract_address + '.txt',
      mnemonic.toString()
    );
    fs.writeFileSync('./mnemonic.txt.txt', mnemonic.toString());
  });

task(
  'account',
  'Get balance informations for the deployment account.',
  async (_, { ethers }) => {
    const hdkey = require('ethereumjs-wallet/hdkey');
    const bip39 = require('bip39');
    let mnemonic = fs.readFileSync('./mnemonic.txt.txt').toString().trim();
    if (DEBUG) console.log('mnemonic', mnemonic);
    const seed = await bip39.mnemonicToSeed(mnemonic);
    if (DEBUG) console.log('seed', seed);
    const hdwallet = hdkey.fromMasterSeed(seed);
    const wallet_hdpath = "m/44'/60'/0'/0/";
    const account_index = 0;
    let fullPath = wallet_hdpath + account_index;
    if (DEBUG) console.log('fullPath', fullPath);
    const wallet = hdwallet.derivePath(fullPath).getWallet();
    const privateKey = '0x' + wallet._privKey.toString('hex');
    if (DEBUG) console.log('privateKey', privateKey);
    var EthUtil = require('ethereumjs-util');
    const address =
      '0x' + EthUtil.privateToAddress(wallet._privKey).toString('hex');

    var qrcode = require('qrcode-terminal');
    qrcode.generate(address);
    console.log('‍📬 Deployer Account is ' + address);
    for (let n in config.networks) {
      //console.log(config.networks[n],n)
      try {
        let provider = new ethers.providers.JsonRpcProvider(
          config.networks[n].url
        );
        let balance = await provider.getBalance(address);
        console.log(' -- ' + n + ' --  -- -- 📡 ');
        console.log('   balance: ' + ethers.utils.formatEther(balance));
        console.log(
          '   nonce: ' + (await provider.getTransactionCount(address))
        );
      } catch (e) {
        if (DEBUG) {
          console.log(e);
        }
      }
    }
  }
);

async function addr(ethers, addr) {
  if (isAddress(addr)) {
    return getAddress(addr);
  }
  const accounts = await ethers.provider.listAccounts();
  if (accounts[addr] !== undefined) {
    return accounts[addr];
  }
  throw `Could not normalize address: ${addr}`;
}

task('accounts', 'Prints the list of accounts', async (_, { ethers }) => {
  const accounts = await ethers.provider.listAccounts();
  accounts.forEach((account) => console.log(account));
});

task('blockNumber', 'Prints the block number', async (_, { ethers }) => {
  const blockNumber = await ethers.provider.getBlockNumber();
  console.log(blockNumber);
});

task('balance', "Prints an account's balance")
  .addPositionalParam('account', "The account's address")
  .setAction(async (taskArgs, { ethers }) => {
    const balance = await ethers.provider.getBalance(
      await addr(ethers, taskArgs.account)
    );
    console.log(formatUnits(balance, 'ether'), 'ETH');
  });

function send(signer, txparams) {
  return signer.sendTransaction(txparams, (error, transactionHash) => {
    if (error) {
      debug(`Error: ${error}`);
    }
    debug(`transactionHash: ${transactionHash}`);
    // checkForReceipt(2, params, transactionHash, resolve)
  });
}

task('send', 'Send ETH')
  .addParam('from', 'From address or account index')
  .addOptionalParam('to', 'To address or account index')
  .addOptionalParam('amount', 'Amount to send in ether')
  .addOptionalParam('data', 'Data included in transaction')
  .addOptionalParam('gasPrice', 'Price you are willing to pay in gwei')
  .addOptionalParam('gasLimit', 'Limit of how much gas to spend')

  .setAction(async (taskArgs, { network, ethers }) => {
    const from = await addr(ethers, taskArgs.from);
    debug(`Normalized from address: ${from}`);
    const fromSigner = await ethers.provider.getSigner(from);

    let to;
    if (taskArgs.to) {
      to = await addr(ethers, taskArgs.to);
      debug(`Normalized to address: ${to}`);
    }

    const txRequest = {
      from: await fromSigner.getAddress(),
      to,
      value: parseUnits(
        taskArgs.amount ? taskArgs.amount : '0',
        'ether'
      ).toHexString(),
      nonce: await fromSigner.getTransactionCount(),
      gasPrice: parseUnits(
        taskArgs.gasPrice ? taskArgs.gasPrice : '1.001',
        'gwei'
      ).toHexString(),
      gasLimit: taskArgs.gasLimit ? taskArgs.gasLimit : 24000,
      chainId: network.config.chainId,
    };

    if (taskArgs.data !== undefined) {
      txRequest.data = taskArgs.data;
      debug(`Adding data to payload: ${txRequest.data}`);
    }
    debug(txRequest.gasPrice / 1000000000 + ' gwei');
    debug(JSON.stringify(txRequest, null, 2));

    return send(fromSigner, txRequest);
  });
