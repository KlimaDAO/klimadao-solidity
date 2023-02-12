// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./keepers/KeeperCompatible.sol";
import "../../helpers/Ownable.sol";

interface IKlimaRetirementAggregator {
    function retireCarbon(
        address _sourceToken,
        address _poolToken,
        uint256 _amount,
        bool _amountInCarbon,
        address _beneficiaryAddress,
        string memory _beneficiaryString,
        string memory _retirementMessage
    ) external;
}

interface IWrappedAsset {
    function deposit() external payable;

    function balanceOf(address user) external;

    function approve(address guy, uint256 wad) external returns (bool);
}

contract SwapRetirementHolder is KeeperCompatibleInterface, Ownable {
    /**
     * Use an interval in seconds and a timestamp to slow execution of Upkeep
     */
    uint256 public interval;
    uint256 public lastTimeStamp;
    uint256 public numPendingRetirementAddresses;
    bool private continueUpKeeping;

    address public WrappedNativeAssetAddress;
    address public sourceCarbonToken;

    IKlimaRetirementAggregator public KlimaAggregator;

    mapping(address => uint256) public pendingRetirementAmounts;
    mapping(uint256 => address) public pendingRetirees;
    mapping(address => uint256) public pendingAddressQueuePosition;

    event intervalUpdated(uint256 newInterval);
    event aggregatorAddressUpdated(address newAddress);
    event newPendingRetirement(address retiree, uint256 amount);
    event newCarbonTokenUpdated(address newCarbonTokenUpdate);

    constructor(
        address _KlimaAggregator,
        uint256 _interval,
        address _wrappedNativeAsset,
        address _carbonToken
    ) {
        KlimaAggregator = IKlimaRetirementAggregator(_KlimaAggregator);

        // set first upkeep check at the interval from now
        lastTimeStamp = block.timestamp + _interval;

        interval = _interval;

        // set native wrapped asset address
        WrappedNativeAssetAddress = _wrappedNativeAsset;

        // set carbon token to use
        // TODO: make this dynamic on upkeep

        sourceCarbonToken = _carbonToken;
    }

    // Change Klima Aggregator address, though its upgradeable so doubtful this will change
    function setKlimaAggregator(address newAggregator) public onlyManager {
        KlimaAggregator = IKlimaRetirementAggregator(newAggregator);
    }

    // Change retirement interval, uint256 in seconds
    function setRetirementInterval(uint256 newInterval) public onlyManager {
        interval = newInterval;
        emit intervalUpdated(interval);
    }

    // Change source carbon token, address of erc20
    function setSourceCarbonToken(address newCarbonToken) public onlyManager {
        sourceCarbonToken = newCarbonToken;
        emit newCarbonTokenUpdated(sourceCarbonToken);
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
        // The checkData is defined when the Upkeep was registered.
    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external override {
        if (
            (block.timestamp - lastTimeStamp) > interval &&
            numPendingRetirementAddresses != 0
        ) {
            //lastTimeStamp = block.timestamp;

            //Start from the ending of the array until you get to 0 in case users continue to swap during the upkeep period
            address retiree = pendingRetirees[
                numPendingRetirementAddresses - 1
            ];
            uint256 amountToRetire = pendingRetirementAmounts[retiree];

            // Deposit the ETH/MATIC to WETH/WMATIC using fallback function of WETH/WMATIC
            IWrappedAsset(WrappedNativeAssetAddress).deposit{
                value: amountToRetire
            }();

            //Approve for use by aggregator
            IWrappedAsset(WrappedNativeAssetAddress).approve(
                address(KlimaAggregator),
                amountToRetire
            );

            // Retire tonnage using wrapped token asset; fire and forget no checks on amount

            KlimaAggregator.retireCarbon(
                WrappedNativeAssetAddress,
                sourceCarbonToken,
                amountToRetire,
                false,
                retiree,
                "Sushiswap Green Txn",
                "Retired using KlimaDAO x Sushi Integration"
            );

            // Reset this user's retirement pending to 0
            pendingRetirees[numPendingRetirementAddresses - 1] = address(0);
            pendingRetirementAmounts[retiree] = 0;

            // Reduce counter by 1
            numPendingRetirementAddresses -= 1;
        } else if (
            ((block.timestamp - lastTimeStamp) > interval &&
                numPendingRetirementAddresses == 0)
        ) {
            // All users have been retired, reset interval
            lastTimeStamp = block.timestamp;
        }
        // We don't use the performData in this example. The performData is generated by the Keeper's call to your checkUpkeep function
    }

    // Admin override in case of odd behavior.

    function storePendingRetirement(
        uint256 amountToStore,
        address addressToStore
    ) public onlyManager {
        if (pendingRetirementAmounts[addressToStore] == 0) {
            pendingRetirees[numPendingRetirementAddresses] = addressToStore;
            pendingRetirementAmounts[addressToStore] += amountToStore;
            numPendingRetirementAddresses += 1;
        } else {
            pendingRetirementAmounts[addressToStore] += amountToStore;
        }
        require(
            pendingRetirementAmounts[addressToStore] != 0,
            "Pending Retirement Record Failed: Pending amount is 0"
        );
    }

    // Replace a pending address with a new address, this is handy because the retirement side of Toucan refuses to send
    // ERC721s to non receiving addresses (aka most smart contracts) and may end up breaking from time to time as a result

    function replaceAddressInPendingRetirement(
        address oldAddress,
        address replacementAddress
    ) public onlyManager {
        require(
            pendingRetirementAmounts[oldAddress] != 0,
            "No pending retirement found"
        );
        pendingRetirees[
            pendingAddressQueuePosition[oldAddress]
        ] = replacementAddress;
    }

    // This nifty contract makes use of the fallback function to detect when native ETH/Matic or any native asset is deposited. It automatically sequesters it for retirement use.

    receive() external payable {
        if (pendingRetirementAmounts[tx.origin] == 0) {
            pendingRetirees[numPendingRetirementAddresses] = tx.origin;
            pendingRetirementAmounts[tx.origin] += msg.value;
            pendingAddressQueuePosition[
                tx.origin
            ] = numPendingRetirementAddresses;
            numPendingRetirementAddresses += 1;
        } else {
            pendingRetirementAmounts[tx.origin] += msg.value;
        }
        require(
            pendingRetirementAmounts[tx.origin] != 0,
            "Pending Retirement Record Failed: Pending amount is 0"
        );
    }

    fallback() external payable {
        if (pendingRetirementAmounts[tx.origin] == 0) {
            pendingRetirees[numPendingRetirementAddresses] = tx.origin;
            pendingRetirementAmounts[tx.origin] += msg.value;
            pendingAddressQueuePosition[
                tx.origin
            ] = numPendingRetirementAddresses;
            numPendingRetirementAddresses += 1;
        } else {
            pendingRetirementAmounts[tx.origin] += msg.value;
        }
        require(
            pendingRetirementAmounts[tx.origin] != 0,
            "Pending Retirement Record Failed: Pending amount is 0"
        );
    }
}
