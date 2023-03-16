// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../AppStorage.sol";

contract InitProjectTotals {
    AppStorage internal s;

    function init() external {
        // Update the project amounts retired for transactions sent through V2 thus far

        s.a[0x20A580444DD4A90Cc8990DA7B480C5E3d605a26f].totalProjectRetired[0xb139C4cC9D20A3618E9a2268D73Eff18C496B991]
        += uint(1_000_000_000_000_000);
        s.a[0x808b891a69f2cF52f84228DA61f2F4F5b08297DE].totalProjectRetired[0xb139C4cC9D20A3618E9a2268D73Eff18C496B991]
        += uint(956_844_938_827);
        s.a[0x808b891a69f2cF52f84228DA61f2F4F5b08297DE].totalProjectRetired[0xb139C4cC9D20A3618E9a2268D73Eff18C496B991]
        += uint(956_844_938_829);
        s.a[0xDdfF75A29EB4BFEcF65380de9a75ad08C140eA49].totalProjectRetired[0xb139C4cC9D20A3618E9a2268D73Eff18C496B991]
        += uint(966_561_401_954_341_706);
        s.a[0x6F9F81eb4f54512Be8c91833783ee0074328E062].totalProjectRetired[0xb139C4cC9D20A3618E9a2268D73Eff18C496B991]
        += uint(1_000_000_000_000_000);
    }
}
