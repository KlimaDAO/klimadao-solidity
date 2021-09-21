

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;


// ██╗  ██╗██╗     ██╗███╗   ███╗ █████╗     ██████╗  █████╗  ██████╗
// ██║ ██╔╝██║     ██║████╗ ████║██╔══██╗    ██╔══██╗██╔══██╗██╔═══██╗
// █████╔╝ ██║     ██║██╔████╔██║███████║    ██║  ██║███████║██║   ██║
// ██╔═██╗ ██║     ██║██║╚██╔╝██║██╔══██║    ██║  ██║██╔══██║██║   ██║
// ██║  ██╗███████╗██║██║ ╚═╝ ██║██║  ██║    ██████╔╝██║  ██║╚██████╔╝
// ╚═╝  ╚═╝╚══════╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═╝ ╚═════╝



import  "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

library Babylonian {

    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;

        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }
}

library BitMath {

    function mostSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0, 'BitMath::mostSignificantBit: zero');

        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            r += 128;
        }
        if (x >= 0x10000000000000000) {
            x >>= 64;
            r += 64;
        }
        if (x >= 0x100000000) {
            x >>= 32;
            r += 32;
        }
        if (x >= 0x10000) {
            x >>= 16;
            r += 16;
        }
        if (x >= 0x100) {
            x >>= 8;
            r += 8;
        }
        if (x >= 0x10) {
            x >>= 4;
            r += 4;
        }
        if (x >= 0x4) {
            x >>= 2;
            r += 2;
        }
        if (x >= 0x2) r += 1;
    }
}

import "../../helpers/libraries/SafeMath.sol";
import "../../helpers/libraries/Address.sol";
import "../../helpers/libraries/FullMath.sol";
import "../../helpers/libraries/FixedPoint.sol";
import "../../helpers/libraries/Counters.sol";
import "../../helpers/libraries/SafeERC20.sol";

//import "../../helpers/interfaces/IERC2612Permit.sol";
import "../../helpers/interfaces/IERC20.sol";
import "../../helpers/interfaces/ITreasury.sol";
import "../../helpers/interfaces/IBondCalculator.sol";
import "../../helpers/interfaces/IStaking.sol";
import "../../helpers/interfaces/IStakingHelper.sol";

import "../../helpers/abstracts/ERC20.sol";
import "../../helpers/abstracts/ERC20Permit.sol";





interface IUniswapV2ERC20 {
    function totalSupply() external view returns (uint);
}

interface IUniswapV2Pair is IUniswapV2ERC20 {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns ( address );
    function token1() external view returns ( address );
}

import "../../helpers/interfaces/IBondCalculator.sol";

contract KlimaBondingCalculatorUpgradeable is IBondCalculator, OwnableUpgradeable {

    using FixedPoint for *;
    using SafeMath for uint;
    using SafeMath for uint112;

    address public KLIMA;

    constructor() {

    }

    function initialize(address _KLIMA) initializer public {
        __Ownable_init();
        __KlimaBondingCalculatorUpgradeable_init(_KLIMA);
    }

    function __KlimaBondingCalculatorUpgradeable_init(address _KLIMA) initializer internal {
        require( _KLIMA != address(0) );
        KLIMA = _KLIMA;
    }

    function getKValue( address _pair ) public view returns( uint k_ ) {
        uint token0 = IERC20( IUniswapV2Pair( _pair ).token0() ).decimals();
        uint token1 = IERC20( IUniswapV2Pair( _pair ).token1() ).decimals();
        uint decimals = token0.add( token1 ).sub( IERC20( _pair ).decimals() );

        (uint reserve0, uint reserve1, ) = IUniswapV2Pair( _pair ).getReserves();
        k_ = reserve0.mul(reserve1).div( 10 ** decimals );
    }

    function getTotalValue( address _pair ) public view returns ( uint _value ) {
        _value = getKValue( _pair ).sqrrt().mul(2);
    }

    function valuation( address _pair, uint amount_ ) external view override returns ( uint _value ) {
        uint totalValue = getTotalValue( _pair );
        uint totalSupply = IUniswapV2Pair( _pair ).totalSupply();

        _value = totalValue.mul( FixedPoint.fraction( amount_, totalSupply ).decode112with18() ).div( 1e18 );
    }

    function markdown( address _pair ) external view override returns ( uint ) {
        ( uint reserve0, uint reserve1, ) = IUniswapV2Pair( _pair ).getReserves();

        uint reserve;
        if ( IUniswapV2Pair( _pair ).token0() == KLIMA ) {
            reserve = reserve1;
        } else {
            reserve = reserve0;
        }
        return reserve.mul( 2 * ( 10 ** IERC20( KLIMA ).decimals() ) ).div( getTotalValue( _pair ) );
    }
}
