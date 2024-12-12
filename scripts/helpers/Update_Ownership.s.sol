// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// This Scripts change the ownership of the V3 contracts from Deployer to the correct addresses. For most of the cases
// ownership will be changed to executor lvl1, and guardian to the aave safes.

import {ZkSyncScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {OwnableWithGuardian} from 'solidity-utils/contracts/access-control/OwnableWithGuardian.sol';
import {GovernanceV3ZkSync} from 'aave-address-book/GovernanceV3ZkSync.sol';

contract ZkSync is ZkSyncScript {
  function run() external {
    vm.startBroadcast();
    OwnableWithGuardian(address(GovernanceV3ZkSync.PAYLOADS_CONTROLLER)).transferOwnership(
      GovernanceV3ZkSync.EXECUTOR_LVL_1
    );
    OwnableWithGuardian(address(GovernanceV3ZkSync.PAYLOADS_CONTROLLER)).updateGuardian(
      GovernanceV3ZkSync.GOVERNANCE_GUARDIAN
    );

    OwnableWithGuardian(GovernanceV3ZkSync.CROSS_CHAIN_CONTROLLER).updateGuardian(
      GovernanceV3ZkSync.GRANULAR_GUARDIAN
    );

    OwnableWithGuardian(GovernanceV3ZkSync.CROSS_CHAIN_CONTROLLER).transferOwnership(
      GovernanceV3ZkSync.EXECUTOR_LVL_1
    );

    vm.stopBroadcast();
  }
}
