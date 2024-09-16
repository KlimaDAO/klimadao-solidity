from woke.testing import *
from woke.testing.fuzzing import *
from pytypes.axelarnetwork.axelargmpsdksolidity.contracts.interfaces.IAxelarExecutable import IAxelarExecutable
from pytypes.axelarnetwork.axelarcgpsolidity.contracts.interfaces.IERC20 import IERC20
from pytypes.axelarnetwork.axelargmpsdksolidity.contracts.deploy.Create3Deployer import Create3Deployer
from pytypes.axelarnetwork.axelarcgpsolidity.contracts.AxelarGateway import AxelarGateway
from pytypes.axelarnetwork.axelarcgpsolidity.contracts.TokenDeployer import TokenDeployer
from pytypes.src.axelar.tests.AuthModuleMock import AuthModuleMock
from pytypes.src.axelar.tests.KlimaInfinityMock import KlimaInfinityMock
from pytypes.src.axelar.PolygonPoSRetire import DefaultRetirementExecutable


chain1 = Chain()
chain2 = Chain()

gw1: AxelarGateway
gw2: AxelarGateway

my_contract1: MyContract
my_contract2: MyContract

POOL_TOKEN = "0x00000000tc02"

def on_revert(f):
    def wrapper(*args, **kwargs):
        try:
            f(*args, **kwargs)
        except TransactionRevertedError as e:
            if e.tx is not None:
                print (e.tx.call_trace)
            raise

    return wrapper


def relay(tx: TransactionAbc) -> None:
    for i, event in enumerate(tx.events):
        if isinstance(event, AxelarGateway.ContractCall):
            if event.destinationChain == "chain1":
                source_chain_str = "chain2"
                source_address_str = str(my_contract2.address)
                destination_chain = chain1
                destination_gw = gw1
            else:
                source_chain_str = "chain1"
                source_address_str = str(my_contract1.address)
                destination_chain = chain2
                destination_gw = gw2
            
            # approve contract call on destination gateway
            command_id = random_bytes(32)
            approve_contract_call_params = Abi.encode(
                ["string", "string", "address", "bytes32", "bytes32", "uint256"],
                [source_chain_str, source_address_str, event.destinationContractAddress, event.payloadHash, bytes.fromhex(tx.tx_hash[2:]), i]
            )
            data = Abi.encode(
                ["uint256", "bytes32[]", "string[]", "bytes[]"],
                [destination_gw.chain.chain_id, [command_id], ["approveContractCall"], [approve_contract_call_params]]
            )
            proof = b""  # not needed because of mocked auth module
            destination_gw.execute(Abi.encode(["bytes", "bytes"], [data, proof]))

            # execute contract call on destination chain
            executable = IAxelarExecutable(event.destinationContractAddress, chain=destination_chain)
            executable.execute(command_id, source_chain_str, source_address_str, event.payload)
        elif isinstance(event, AxelarGateway.ContractCallWithToken):
            if event.destinationChain == "chain1":
                source_chain_str = "chain2"
                source_address_str = str(my_contract2.address)
                destination_chain = chain1
                destination_gw = gw1
            else:
                source_chain_str = "chain1"
                source_address_str = str(my_contract1.address)
                destination_chain = chain2
                destination_gw = gw2
            
            # approve contract call with token on destination gateway
            command_id = random_bytes(32)
            approve_contract_call_with_token_params = Abi.encode(
                ["string", "string", "address", "bytes32", "string", "uint256", "bytes32", "uint256"],
                [source_chain_str, source_address_str, event.destinationContractAddress, event.payloadHash, event.symbol, event.amount, bytes.fromhex(tx.tx_hash[2:]), i]
            )
            data = Abi.encode(
                ["uint256", "bytes32[]", "string[]", "bytes[]"],
                [destination_gw.chain.chain_id, [command_id], ["approveContractCallWithMint"], [approve_contract_call_with_token_params]]
            )
            proof = b""  # not needed because of mocked auth module
            destination_gw.execute(Abi.encode(["bytes", "bytes"], [data, proof]))
            
            # execute contract call with token on destination chain
            executable = IAxelarExecutable(event.destinationContractAddress, chain=destination_chain)
            executable.executeWithToken(command_id, source_chain_str, source_address_str, event.payload, event.symbol, event.amount)
        elif isinstance(event, (
            MyContract.PayloadReceived,
            MyContract.PayloadWithTokenReceived,
        )):
            print(event)


def deploy_token(
    gw: AxelarGateway,
    name: str,
    symbol: str,
    decimals: uint8,
    cap: uint256,
    mint_limit: uint256,
    token_address: Optional[Address] = None,
) -> Address:
    command_id = random_bytes(32)
    deploy_token_params = Abi.encode(
        ["string", "string", "uint8", "uint256", "address", "uint256"],
        [name, symbol, decimals, cap, Address(0) if token_address is None else token_address, mint_limit]
    )

    data = Abi.encode(
        ["uint256", "bytes32[]", "string[]", "bytes[]"],
        [gw.chain.chain_id, [command_id], ["deployToken"], [deploy_token_params]]
    )
    proof = b""
    tx = gw.execute(Abi.encode(["bytes", "bytes"], [data, proof]))
    deploy_events = [e for e in tx.events if isinstance(e, AxelarGateway.TokenDeployed)]
    assert len(deploy_events) == 1
    return deploy_events[0].tokenAddresses


def mint(
    gw: AxelarGateway,
    symbol: str,
    recipient: Address,
    amount: uint256,
):
    command_id = random_bytes(32)
    mint_token_params = Abi.encode(
        ["string", "address", "uint256"],
        [symbol, recipient, amount]
    )

    data = Abi.encode(
        ["uint256", "bytes32[]", "string[]", "bytes[]"],
        [gw.chain.chain_id, [command_id], ["mintToken"], [mint_token_params]]
    )
    proof = b""
    gw.execute(Abi.encode(["bytes", "bytes"], [data, proof]))


@chain1.connect()
@chain2.connect()
@on_revert
def test_default():
    global gw1, gw2, my_contract1, my_contract2

    chain1.set_default_accounts(chain1.accounts[0])
    chain2.set_default_accounts(chain2.accounts[0])

    chain1.tx_callback = relay
    chain2.tx_callback = relay

    # check that client-owned accounts are the same on both chains
    assert chain1.accounts[1].address == chain2.accounts[1].address
    owner = chain1.accounts[1].address

    am1 = AuthModuleMock.deploy(chain=chain1)
    am2 = AuthModuleMock.deploy(chain=chain2)

    td1 = TokenDeployer.deploy(chain=chain1)
    td2 = TokenDeployer.deploy(chain=chain2)

    gw1 = AxelarGateway.deploy(am1, td1, chain=chain1)
    gw2 = AxelarGateway.deploy(am2, td2, chain=chain2)

    rm = KlimaInfinityMock.deploy(chain=chain2)

    token1 = IERC20(deploy_token(gw1, "My Token", "MTK", 18, 2**256-1, 2**256-1), chain=chain1)
    token2 = IERC20(deploy_token(gw2, "My Token", "MTK", 18, 2**256-1, 2**256-1), chain=chain2)

    deployer1 = Create3Deployer.deploy(chain=chain1)
    deployer2 = Create3Deployer.deploy(chain=chain2)

    # deploy implementation contracts with create3 to achieve the same address on both chains
    # with fixed destination chain in constructors!
    salt = random_bytes(32)
    my_contract1 = DefaultRetirementExecutable(
        deployer1.deploy_(
            DefaultRetirementExecutable.get_creation_code() + Abi.encode(
                ["address"], [gw1.address], chain2.chain_id
            ), salt).return_value,
        chain=chain1
    )
    my_contract2 = DefaultRetirementExecutable(
        deployer2.deploy_(
            DefaultRetirementExecutable.get_creation_code() + Abi.encode(
                ["address"], [gw2.address], chain2.chain_id
            ), salt).return_value,
        chain=chain2
    )
    assert my_contract1.address == my_contract2.address

    # mint 100 tokens on chain1 and send them to my_contract1
    mint(gw1, "MTK", my_contract1.address, 100)
    assert token1.balanceOf(my_contract1) == 100

    # initiate retirement with 100 tokens from my_contract1 to my_contract2
    my_contract1.retireDefaultViaPolygonPoS(
        POOL_TOKEN,
        100,
        "Retiring Entity",
        "0x0000000retiree",
        "Big Emitter Inc.",
        "Offsetting emissions",
        "MTK", 100
    )
    assert token1.balanceOf(my_contract1) == 0
    assert token2.balanceOf(my_contract2) == 0
    assert token2.balanceOf(rm.unretrievableAddress) == 100


