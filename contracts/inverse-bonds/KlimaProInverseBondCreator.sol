// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.6;

import "./types/EnumerableMap.sol";

import "../bonds-v2/types/KlimaAccessControlled.sol";
import "../bonds-v2/interfaces/IKlimaAuthority.sol";
import "./interfaces/IKlimaPro.sol";
import "../bonds-v2/interfaces/ITreasury.sol";
import "../bonds-v2/interfaces/IERC20.sol";
import "../bonds-v2/interfaces/IKLIMA.sol";

contract KlimaInverseBondCreator is KlimaAccessControlled {
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    IKlimaPro public depository;
    ITreasury public treasury;
    IKLIMA public klima;

    EnumerableMap.UintToAddressMap private markets;

    constructor(IKLIMA _klima, ITreasury _treasury, IKlimaPro _depository, IKlimaAuthority _authority)
    KlimaAccessControlled(_authority)
    {
        klima = _klima;
        treasury = _treasury;
        depository = _depository;
    }

    // creates a market selling reserves for klima
    // bonds have no vesting (executes an instant swap)
    // see IProMarketCreator for _market and _intervals arguments
    // _conclusion is concluding timestamp
    function create(
        IERC20 _token,
        uint256[4] memory _market,
        uint32[2] memory _intervals,
        uint256 _conclusion
    ) onlyPolicy external {
        IERC20[2] memory tokens = [_token, klima];
        bool[2] memory booleans = [false, true];
        uint256[2] memory terms = [0, _conclusion];

        treasury.manage(address(_token), _market[0]);

        // approve tokens on depository and treasury (for return if needed)
        // add to the current allowances since there can be multiple markets
        _token.approve(address(depository), _market[0] + _token.allowance(address(this), address(depository)));
        _token.approve(address(treasury), _market[0] + _token.allowance(address(this), address(treasury)));

        uint256 id = depository.create(
            tokens,
            _market,
            booleans,
            terms,
            _intervals
        );

        markets.set(id, address(_token));
    }

    // Sets the treasury address to call manage on
    function setTreasury(address _treasury) external onlyPolicy {
        treasury = ITreasury(_treasury);
    }

    // halt all markets by revoking approval
    function halt(uint256 _id) external onlyPolicy {
        IERC20 token = IERC20(markets.get(_id));
        token.approve(address(depository), 0);
    }

    // close a market
    function close(uint256 _id) external onlyPolicy {
        markets.remove(_id);
        depository.close(_id);
    }

    // burn repurchased klima
    function burn() external onlyPolicy {
        klima.burn(klima.balanceOf(address(this)));
    }

    // return the rest of the tokens in this contract
    function returnReserve(address _token, uint256 amount) external onlyPolicy {
        treasury.deposit(amount, _token, treasury.tokenValue(_token, amount));
    }

    // function to get all active markets created by this contract
    function getMarkets() external view returns (uint256[] memory, address[] memory) {
        uint256 length = markets.length();
        uint256[] memory activeMarketIds = new uint256[](length);
        address[] memory activeMarketTokens = new address[](length);

        for (uint256 i = 0; i < length; i++) {
            (activeMarketIds[i], activeMarketTokens[i]) = markets.at(i);
        }

        return (activeMarketIds, activeMarketTokens);
    }
}
