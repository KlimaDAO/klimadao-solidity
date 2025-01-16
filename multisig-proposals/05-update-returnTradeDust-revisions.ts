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
  data: "0x1f931c1c00000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000032000000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000001e00000000000000000000000000c004e8571978696eb8a4bb2aece547f8b2fce0c000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000002ee2342a000000000000000000000000000000000000000000000000000000000a8c7b63600000000000000000000000000000000000000000000000000000000000000000000000000000000016c3a81ccef9e2a7b963cb23b7f71a4c11019720000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000029ba61b13000000000000000000000000000000000000000000000000000000007af2e728000000000000000000000000000000000000000000000000000000000000000000000000000000004fd46d5f67f4297ceffa5cb9c43e080cbb85d2500000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000021c79d29a000000000000000000000000000000000000000000000000000000002eb3eb0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
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
