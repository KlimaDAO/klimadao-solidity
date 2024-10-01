import SafeApiKit from "@safe-global/api-kit";
import Safe from "@safe-global/protocol-kit";
import {
  MetaTransactionData,
  OperationType,
} from "@safe-global/safe-core-sdk-types";

const RPC_URL = process.env.SEPOLIA_URL;
const SAFE_ADDRESS = process.env.SAFE_ADDRESS;
const OWNER_1_PRIVATE_KEY = process.env.PRIVATE_KEY;
const OWNER_1_ADDRESS = process.env.OWNER_1_ADDRESS;

const RETIREMENT_AGGREGATOR = process.env.RETIREMENT_AGGREGATOR;

// Sepolia for testing
const apiKit = new SafeApiKit({
  chainId: 11155111n,
});

if (!RPC_URL || !OWNER_1_PRIVATE_KEY || !OWNER_1_ADDRESS || !SAFE_ADDRESS || !RETIREMENT_AGGREGATOR) {
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
  value: "0", // 1 wei
  data: "0x000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000140000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000004b0848114979e047a1264f986e4b36429c0c81bc00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000174deb0be000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
  operation: OperationType.Call,
};

const safeTransaction = await protocolKitOwner1.createTransaction({
  transactions: [safeTransactionData],
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
