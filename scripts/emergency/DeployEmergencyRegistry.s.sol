// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Ownable} from 'openzeppelin-contracts/contracts/access/Ownable.sol';
import 'adi-scripts/emergency/Deploy_EmergencyRegistry.sol';
import '../BaseDeployerScript.sol';

abstract contract DeployEmergencyRegistry is BaseDeployerScript, BaseDeployEmergencyMode {
  function _execute(Addresses memory addresses) internal override {
    addresses.emergencyRegistry = _deployEmergencyRegistry();
    Ownable(address(addresses.emergencyRegistry)).transferOwnership(OWNER());
  }
}

contract Ethereum is DeployEmergencyRegistry {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}

contract Ethereum_testnet is DeployEmergencyRegistry {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}
