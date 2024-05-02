// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './BaseAdapterScript.sol';
import {BaseArbAdapter, IBaseAdapter} from 'adi-scripts/adapters/arbitrum/DeployArbAdapter.sol';

contract DeployArbAdapter is BaseAdapterScript, BaseArbAdapter {
  function REMOTE_NETWORKS(
    ChainDeploymentInfo memory config
  ) internal pure override returns (uint256[] memory) {
    return config.adapters.arbitrumAdapter.remoteNetworks;
  }

  function _deployAdapter(
    address crossChainController,
    Addresses memory currentAddresses,
    Addresses memory revisionAddresses,
    ChainDeploymentInfo memory config,
    IBaseAdapter.TrustedRemotesConfig[] memory trustedRemotes
  ) internal override {
    require(crossChainController != address(0), 'CCC needs to be deployed');

    EndpointAdapterInfo memory arbConfig = config.adapters.arbitrumAdapter;

    address arbAdapter;
    if (PathHelpers.isTestNet(config.chainId)) {
      address destinationCCC;
      if (config.chainId == TestNetChainIds.ETHEREUM_SEPOLIA) {
        // fetch current addresses
        Addresses memory remoteCurrentAddresses = _getCurrentAddressesByChainId(
          TestNetChainIds.ARBITRUM_SEPOLIA,
          vm
        );
        // fetch revision addresses
        Addresses memory remoteRevisionAddresses = _getRevisionAddressesByChainId(
          TestNetChainIds.ARBITRUM_SEPOLIA,
          config.revision,
          vm
        );
        destinationCCC = _getCrossChainController(
          remoteCurrentAddresses,
          remoteRevisionAddresses,
          TestNetChainIds.ARBITRUM_SEPOLIA
        );

        require(arbConfig.endpoint != address(0), 'Arbitrum inbox can not be 0');
        require(destinationCCC != address(0), 'Arbitrum CCC must be deployed');
      }

      arbAdapter = _deployAdapter(
          crossChainController,
          arbConfig.endpoint,
          destinationCCC,
          arbConfig.providerGasLimit,
          trustedRemotes,
          true,
        keccak256(salt)

      );
    } else {
      address destinationCCC;
      if (config.chainId == ChainIds.ETHEREUM) {
        // fetch current addresses
        Addresses memory remoteCurrentAddresses = _getCurrentAddressesByChainId(
          ChainIds.ARBITRUM,
          vm
        );
        // fetch revision addresses
        Addresses memory remoteRevisionAddresses = _getRevisionAddressesByChainId(
          ChainIds.ARBITRUM,
          config.revision,
          vm
        );
        destinationCCC = _getCrossChainController(
          remoteCurrentAddresses,
          remoteRevisionAddresses,
          TestNetChainIds.ARBITRUM_SEPOLIA
        );

        require(arbConfig.endpoint != address(0), 'Arbitrum inbox can not be 0');
        require(destinationCCC != address(0), 'Arbitrum CCC must be deployed');
      }
      arbAdapter = _deployAdapter(
        crossChainController,
        arbConfig.endpoint,
        destinationCCC,
        arbConfig.providerGasLimit,
        trustedRemotes,
        true,
        keccak256(salt)

      );
    }

    currentAddresses.arbAdapter = revisionAddresses.arbAdapter = arbAdapter;
  }
}

//{
//ethereum_inbox: 0x4Dbd4fc535Ac27206064B68FfCf827b0A60BAB3f
//}
