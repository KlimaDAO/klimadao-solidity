// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";



contract AlphaKlimaRedeemUpgradeable is ERC2771ContextUpgradeable  {
    using SafeMathUpgradeable for uint256;

    IERC20Upgradeable public KLIMA;
    IERC20Upgradeable public aKLIMA;

    address public owner;

    modifier onlyOwner() {
        require(_msgSender() == owner, "Owner: caller does not have the the owner role");
        _;
    }

    event klimaRedeemed(address tokenOwner, uint256 amount);

    function initialize (
        address _KLIMA,
        address _aKLIMA,
        address __trustedForwarder
    ) public initializer {
        __ERC2771Context_init_unchained(__trustedForwarder);
        __AlphaKlimaRedeemUpgradeable_init(_KLIMA, _aKLIMA);
        owner = _msgSender();
    }

    function __AlphaKlimaRedeemUpgradeable_init(address _KLIMA,
        address _aKLIMA) internal initializer {
        KLIMA = IERC20Upgradeable(_KLIMA);
        aKLIMA = IERC20Upgradeable(_aKLIMA);
    }

    function migrate(uint256 amount) public {
        require(
            aKLIMA.balanceOf(_msgSender()) >= amount,
            "Error: Cannot Redeem More than User Balance"
        );

        aKLIMA.transferFrom(_msgSender(), address(this), amount);
        KLIMA.transfer(_msgSender(), amount.div(1e9));

        emit klimaRedeemed(_msgSender(), amount);

    }

    function withdraw() external onlyOwner {
        uint256 amount = KLIMA.balanceOf(address(this));

        KLIMA.transfer(_msgSender(), amount);
    }
    function setTrustedForwarder(address newForwarder) public onlyOwner {
        _trustedForwarder = newForwarder;
    }
}
