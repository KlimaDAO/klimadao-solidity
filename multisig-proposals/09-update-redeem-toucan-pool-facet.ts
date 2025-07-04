import SafeApiKit from "@safe-global/api-kit";
import Safe from "@safe-global/protocol-kit";
import {
  MetaTransactionData,
  OperationType,
} from "@safe-global/safe-core-sdk-types";

const RPC_URL = process.env.POLYGON_URL;
const SAFE_ADDRESS = process.env.CONTRACT_MULTISIG;
const OWNER_1_PRIVATE_KEY = process.env.PRIVATE_KEY;
const OWNER_1_ADDRESS = process.env.PUBLIC_KEY;
const RETIREMENT_AGGREGATOR = process.env.RETIREMENT_AGGREGATOR;

// Sepolia for testing
const apiKit = new SafeApiKit({
  chainId: 137n,
});

if (
  !RPC_URL ||
  !OWNER_1_PRIVATE_KEY ||
  !OWNER_1_ADDRESS ||
  !SAFE_ADDRESS ||
  !RETIREMENT_AGGREGATOR
) {
  throw new Error("Missing environment variables");
}

const protocolKitOwner1 = await Safe.init({
  provider: RPC_URL,
  signer: OWNER_1_PRIVATE_KEY,
  safeAddress: SAFE_ADDRESS,
});

// Create transaction
const safeTransactionData: MetaTransactionData = {
  to: RETIREMENT_AGGREGATOR,
  value: "0",
  data: "0x1f931c1c000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000160000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000006dc702e197722d752e760e2ebc63ce6b07fe66e70000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000029ba61b13000000000000000000000000000000000000000000000000000000007af2e728000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", // txn call data generated by running upgrade script
  operation: OperationType.Call,
};

const nextNonce = await apiKit.getNextNonce(SAFE_ADDRESS);

const safeTransaction = await protocolKitOwner1.createTransaction({
  transactions: [safeTransactionData],
  options: {
    nonce: nextNonce,
  },
});

const safeTxHash = await protocolKitOwner1.getTransactionHash(safeTransaction);
const signature = await protocolKitOwner1.signHash(safeTxHash);

// Propose transaction to the service
await apiKit.proposeTransaction({
  safeAddress: SAFE_ADDRESS,
  safeTransactionData: safeTransaction.data,
  safeTxHash,
  senderAddress: OWNER_1_ADDRESS,
  senderSignature: signature.data,
});
