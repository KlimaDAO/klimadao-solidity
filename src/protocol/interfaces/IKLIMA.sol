// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "oz/token/ERC20/utils/SafeERC20.sol";

interface IKlima is IERC20 {
    function mint(address account_, uint amount_) external;

    function burn(uint amount) external;

    function burnFrom(address account_, uint amount_) external;
}

interface IKlimaTreasury {
    function excessReserves() external returns (uint);

    function manage(address _token, uint _amount) external;

    function queue(uint8 _managing, address _address) external returns (bool);

    function toggle(uint8 _managing, address _address, address _calculator) external returns (bool);

    function ReserveManagerQueue(address _address) external returns (uint);

    function isReserveManager(address _address) external returns (bool);
}

interface IKlimaRetirementBond {
    function owner() external returns (address);

    function allocatorContract() external returns (address);

    function DAO() external returns (address);

    function TREASURY() external returns (address);

    function openMarket(address poolToken) external;

    function closeMarket(address poolToken) external;

    function updateMaxSlippage(address poolToken, uint _maxSlippage) external;

    function updateDaoFee(address poolToken, uint _daoFee) external;

    function setPoolReference(address poolToken, address referenceToken) external;
}

interface IRetirementBondAllocator {
    function owner() external returns (address);

    function fundBonds(address token, uint amount) external;

    function closeBonds(address token) external;

    function updateBondContract(address _bondContract) external;

    function updateMaxReservePercent(uint _maxReservePercent) external;

    function maxReservePercent() external view returns (uint);

    function PERCENT_DIVISOR() external view returns (uint);
}
