// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
  GranularGuardianAccessControl
} from 'adi/access_control/GranularGuardianAccessControl.sol';

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
    // Get the current retry role guardian
    address oldRetryRoleGuardian = GranularGuardianAccessControl(GRANULAR_GUARDIAN).getRoleAdmin(
      GranularGuardianAccessControl.RETRY_ROLE()
    );

    // Grant the new guardian the retry role
    GranularGuardianAccessControl(GRANULAR_GUARDIAN).grantRole(
      GranularGuardianAccessControl.RETRY_ROLE(),
      NEW_RETRY_GUARDIAN
    );

    // Revoke retry role from the old guardian
    GranularGuardianAccessControl(GRANULAR_GUARDIAN).revokeRole(
      GranularGuardianAccessControl.RETRY_ROLE(),
      oldRetryRoleGuardian
    );
  }
}
