pragma solidity ^0.8.10;

import "../interfaces/IKlimaAuthority.sol";

error UNAUTHORIZED();
error AUTHORITY_INITIALIZED();

/// @dev Reasoning for this contract = modifiers literaly copy code
/// instead of pointing towards the logic to execute. Over many
/// functions this bloats contract size unnecessarily.
/// imho modifiers are a meme.
abstract contract KlimaAccessControlledV2 {
    /* ========== EVENTS ========== */

    event AuthorityUpdated(IKlimaAuthority authority);

    /* ========== STATE VARIABLES ========== */

    IKlimaAuthority public authority;

    /* ========== Constructor ========== */

    constructor(IKlimaAuthority _authority) {
        authority = _authority;
        emit AuthorityUpdated(_authority);
    }

    /* ========== "MODIFIERS" ========== */

    modifier onlyGovernor {
	_onlyGovernor();
	_;
    }

    modifier onlyGuardian {
	_onlyGuardian();
	_;
    }

    modifier onlyPolicy {
	_onlyPolicy();
	_;
    }

    modifier onlyVault {
	_onlyVault();
	_;
    }

    /* ========== GOV ONLY ========== */

    function initializeAuthority(IKlimaAuthority _newAuthority) internal {
        if (authority != IKlimaAuthority(address(0))) revert AUTHORITY_INITIALIZED();
        authority = _newAuthority;
        emit AuthorityUpdated(_newAuthority);
    }

    function setAuthority(IKlimaAuthority _newAuthority) external {
        _onlyGovernor();
        authority = _newAuthority;
        emit AuthorityUpdated(_newAuthority);
    }

    /* ========== INTERNAL CHECKS ========== */

    function _onlyGovernor() internal view {
        if (msg.sender != authority.governor()) revert UNAUTHORIZED();
    }

    function _onlyGuardian() internal view {
        if (msg.sender != authority.guardian()) revert UNAUTHORIZED();
    }

    function _onlyPolicy() internal view {
        if (msg.sender != authority.policy()) revert UNAUTHORIZED();
    }

    function _onlyVault() internal view {
        if (msg.sender != authority.vault()) revert UNAUTHORIZED();
    }
}
