// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
    @title Klima Retirement Storage
    @notice This is used to store any offset retirements made through Klima retirement helper contracts.
 */
contract KlimaCarbonRetirements is Ownable {
    struct Retirement {
        uint256 totalRetirements;
        uint256 totalCarbonRetired;
        uint256 totalClaimed;
        mapping(uint256 => address) retiredPool;
        mapping(uint256 => uint256) retiredAmount;
        mapping(uint256 => string) retirementBeneficiary;
        mapping(uint256 => string) retirementMessage;
        mapping(address => uint256) totalPoolRetired;
    }

    mapping(address => Retirement) public retirements;
    mapping(address => bool) public isHelperContract;
    mapping(address => bool) public isMinterContract;

    event HelperAdded(address helper);
    event HelperRemoved(address helper);
    event MinterAdded(address minter);
    event MinterRemoved(address minter);

    /**
        @notice Stores the details of an offset transaction for future use
        @param _retiree Address of the retiree. Not the address of a helper contract.
        @param _pool Address of the carbon pool token.
        @param _amount Number of tons offset. Expected is with 18 decimals.
        @param _beneficiaryString String that can be used to describe the beneficiary
        @param _retirementMessage String for specific retirement message if needed.
     */
    function carbonRetired(
        address _retiree,
        address _pool,
        uint256 _amount,
        string calldata _beneficiaryString,
        string calldata _retirementMessage
    ) public {
        require(
            isHelperContract[msg.sender],
            "Caller is not a defined helper contract"
        );

        Retirement storage info = retirements[_retiree];

        info.retiredPool[info.totalRetirements] = _pool;
        info.retiredAmount[info.totalRetirements] = _amount;
        info.retirementBeneficiary[info.totalRetirements] = _beneficiaryString;
        info.retirementMessage[info.totalRetirements] = _retirementMessage;
        info.totalCarbonRetired += _amount;
        unchecked {
            info.totalPoolRetired[_pool] += _amount;
            info.totalRetirements += 1;
        }
    }

    /**
        @notice Return any unclaimed NFT totals for an address
        @param _minter Address of user trying to mint.
        @return The net amount of offsets not used for minting an NFT to date.
     */
    function getUnclaimedTotal(address _minter) public view returns (uint256) {
        return
            retirements[_minter].totalCarbonRetired -
            retirements[_minter].totalClaimed;
    }

    /**
        @notice This function updates the total claimed amount for minting an NFT.
        @param _minter Address of the user trying to mint.
        @param _amount Amount being claimed for the mint. Expected value in 18 decimals.
     */
    function offsetClaimed(address _minter, uint256 _amount)
        public
        returns (bool)
    {
        require(
            isMinterContract[_minter],
            "Contract is not an approved minter."
        );
        require(
            getUnclaimedTotal(_minter) >= _amount,
            "Trying to claim too many offsets"
        );

        Retirement storage info = retirements[_minter];
        info.totalClaimed += _amount;
        return true;
    }

    /**
        @notice This returns information on a specific retirement for an address.
        @param _retiree Address that retired the offsets.
        @param _index Index of all retirements made. Starts at 0.
        @return Returns a tuple of the address for the pool address, amount offset in 18 decimals, and beneficiary description and message used in the retirement.
     */
    function getRetirementIndexInfo(address _retiree, uint256 _index)
        public
        view
        returns (
            address,
            uint256,
            string memory,
            string memory
        )
    {
        return (
            retirements[_retiree].retiredPool[_index],
            retirements[_retiree].retiredAmount[_index],
            retirements[_retiree].retirementBeneficiary[_index],
            retirements[_retiree].retirementMessage[_index]
        );
    }

    /**
        @notice This returns the total amount offset by an address for a specific pool.
        @param _retiree Address that performed the retirement.
        @param _pool Address of the pool token.
        @return Int with 18 decimals for the total amount offset for this pool token.
     */
    function getRetirementPoolInfo(address _retiree, address _pool)
        public
        view
        returns (uint256)
    {
        return retirements[_retiree].totalPoolRetired[_pool];
    }

    /**
        @notice This returns totals about retirements and claims on an address
        @param _retiree Address that performed the retirement.
        @return Int tuple. Total retirements, total tons retired, total tons claimed for NFTs.
     */
    function getRetirementTotals(address _retiree)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (
            retirements[_retiree].totalRetirements,
            retirements[_retiree].totalCarbonRetired,
            retirements[_retiree].totalClaimed
        );
    }

    /**
        @notice Allow contract owner to whitelist new helper contracts. This is to prevent writing abuse from external interfaces.
        @param _helper Address of the helper contract.
     */
    function addHelperContract(address _helper) public onlyOwner {
        require(!isHelperContract[_helper], "Helper already added.");
        require(_helper != address(0));
        isHelperContract[_helper] = true;
        emit HelperAdded(_helper);
    }

    /**
        @notice Allow contract owner to remove helper contracts. This is to prevent writing abuse from external interfaces.
        @param _helper Address of the helper contract.
     */
    function removeHelperContract(address _helper) public onlyOwner {
        require(isHelperContract[_helper], "Helper is not on the list");
        isHelperContract[_helper] = false;
        emit HelperRemoved(_helper);
    }

    /**
        @notice Allow contract owner to whitelist new reward contracts. This is to prevent writing abuse from external interfaces.
        @param _minter Address of the helper contract.
     */
    function addMinterContract(address _minter) public onlyOwner {
        require(!isMinterContract[_minter], "Minter already added.");
        require(_minter != address(0));
        isMinterContract[_minter] = true;
        emit MinterAdded(_minter);
    }

    /**
        @notice Allow contract owner to remove reward contracts. This is to prevent writing abuse from external interfaces.
        @param _minter Address of the helper contract.
     */
    function removeMinterContract(address _minter) public onlyOwner {
        require(isMinterContract[_minter], "Minter is not on the list");
        isMinterContract[_minter] = false;
        emit MinterRemoved(_minter);
    }
}
