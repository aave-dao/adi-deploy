// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GranularGuardianAccessControl} from 'adi/access_control/GranularGuardianAccessControl.sol';

struct GGRetryRoleMigrationArgs {
  address granularGuardian;
  address newRetryGuardian;
}

contract RetryRoleMigrationPayload {
  address public immutable GRANULAR_GUARDIAN;
  address public immutable NEW_RETRY_GUARDIAN;

  constructor(GGRetryRoleMigrationArgs memory args) {
    GRANULAR_GUARDIAN = args.granularGuardian;
    NEW_RETRY_GUARDIAN = args.newRetryGuardian;
  }

  function execute() public {
    GranularGuardianAccessControl granularGuardian = GranularGuardianAccessControl(
      GRANULAR_GUARDIAN
    );
    // Get the current retry role guardian
    address oldRetryRoleGuardian = granularGuardian.getRoleMember(granularGuardian.RETRY_ROLE(), 0);

    // Grant the new guardian the retry role
    granularGuardian.grantRole(granularGuardian.RETRY_ROLE(), NEW_RETRY_GUARDIAN);

    // Revoke retry role from the old guardian
    granularGuardian.revokeRole(granularGuardian.RETRY_ROLE(), oldRetryRoleGuardian);
  }
}
