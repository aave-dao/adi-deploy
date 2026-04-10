// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import {IWithGuardian} from 'solidity-utils/contracts/access-control/OwnableWithGuardian.sol';
import {OwnableWithGuardian} from 'solidity-utils/contracts/access-control/OwnableWithGuardian.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GovernanceV3Polygon} from 'aave-address-book/GovernanceV3Polygon.sol';
import {GovernanceV3Avalanche} from 'aave-address-book/GovernanceV3Avalanche.sol';
import {GovernanceV3BNB} from 'aave-address-book/GovernanceV3BNB.sol';
import {GovernanceV3Gnosis} from 'aave-address-book/GovernanceV3Gnosis.sol';
import {GovernanceV3Metis} from 'aave-address-book/GovernanceV3Metis.sol';
import {GovernanceV3Optimism} from 'aave-address-book/GovernanceV3Optimism.sol';
import {GovernanceV3Arbitrum} from 'aave-address-book/GovernanceV3Arbitrum.sol';
import {GovernanceV3Base} from 'aave-address-book/GovernanceV3Base.sol';
import {GovernanceV3Scroll} from 'aave-address-book/GovernanceV3Scroll.sol';

contract GenerateGuardianMigrationCalldata is Script {
  struct NetworkConfig {
    string name;
    address crossChainController;
    address granularGuardian;
  }

  function run() external view {
    NetworkConfig[] memory networks = _getNetworks();

    console.log('=== Guardian Migration Calldata ===');
    console.log('Function: updateGuardian(address)');
    console.log('');

    for (uint256 i = 0; i < networks.length; i++) {
      NetworkConfig memory net = networks[i];
      bytes memory callData = abi.encodeWithSelector(
        IWithGuardian.updateGuardian.selector,
        net.granularGuardian
      );

      console.log('-----------------------------------');
      console.log('Network:', net.name);
      console.log('Target (CCC):', net.crossChainController);
      console.log('New Guardian:', net.granularGuardian);
      console.log('Calldata:');
      console.logBytes(callData);
      console.log('');
    }
  }

  function _getNetworks() internal pure returns (NetworkConfig[] memory) {
    NetworkConfig[] memory networks = new NetworkConfig[](10);

    networks[0] = NetworkConfig({
      name: 'Ethereum',
      crossChainController: GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER,
      granularGuardian: GovernanceV3Ethereum.GRANULAR_GUARDIAN
    });

    networks[1] = NetworkConfig({
      name: 'Polygon',
      crossChainController: GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER,
      granularGuardian: GovernanceV3Polygon.GRANULAR_GUARDIAN
    });

    networks[2] = NetworkConfig({
      name: 'Avalanche',
      crossChainController: GovernanceV3Avalanche.CROSS_CHAIN_CONTROLLER,
      granularGuardian: GovernanceV3Avalanche.GRANULAR_GUARDIAN
    });

    networks[3] = NetworkConfig({
      name: 'BNB',
      crossChainController: GovernanceV3BNB.CROSS_CHAIN_CONTROLLER,
      granularGuardian: GovernanceV3BNB.GRANULAR_GUARDIAN
    });

    networks[4] = NetworkConfig({
      name: 'Gnosis',
      crossChainController: GovernanceV3Gnosis.CROSS_CHAIN_CONTROLLER,
      granularGuardian: GovernanceV3Gnosis.GRANULAR_GUARDIAN
    });

    networks[5] = NetworkConfig({
      name: 'Metis',
      crossChainController: GovernanceV3Metis.CROSS_CHAIN_CONTROLLER,
      granularGuardian: GovernanceV3Metis.GRANULAR_GUARDIAN
    });

    networks[6] = NetworkConfig({
      name: 'Optimism',
      crossChainController: GovernanceV3Optimism.CROSS_CHAIN_CONTROLLER,
      granularGuardian: GovernanceV3Optimism.GRANULAR_GUARDIAN
    });

    networks[7] = NetworkConfig({
      name: 'Arbitrum',
      crossChainController: GovernanceV3Arbitrum.CROSS_CHAIN_CONTROLLER,
      granularGuardian: GovernanceV3Arbitrum.GRANULAR_GUARDIAN
    });

    networks[8] = NetworkConfig({
      name: 'Base',
      crossChainController: GovernanceV3Base.CROSS_CHAIN_CONTROLLER,
      granularGuardian: GovernanceV3Base.GRANULAR_GUARDIAN
    });

    networks[9] = NetworkConfig({
      name: 'Scroll',
      crossChainController: GovernanceV3Scroll.CROSS_CHAIN_CONTROLLER,
      granularGuardian: GovernanceV3Scroll.GRANULAR_GUARDIAN
    });

    return networks;
  }
}
