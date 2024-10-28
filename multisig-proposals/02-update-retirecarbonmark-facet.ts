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
  data: "0x1f931c1c00000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000020000000000000000000000000118cc2ab0bac2ff9bd17b23c26c5b0976ac16f0c00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000174deb0be000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000", // Add txn call data generated by running upgrade script
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