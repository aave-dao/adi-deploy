// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'adi-scripts/Adapters/DeployZkSyncAdapter.sol';
import '../BaseDeployerScript.sol';

abstract contract DeployZkSyncAdapter is BaseDeployerScript, BaseZkSyncAdapter {
  function _execute(Addresses memory addresses) internal virtual override {
    if (TRANSACTION_NETWORK() == ChainIds.ZKSYNC) {
      addresses.zksyncAdapter = _deployWithoutCreate2(
        BaseAdapterArgs({
          crossChainController: addresses.crossChainController,
          providerGasLimit: PROVIDER_GAS_LIMIT(),
          trustedRemotes: _getTrustedRemotes(),
          isTestnet: isTestnet()
        })
      );
    } else {
      addresses.zksyncAdapter = _deployAdapter(addresses.crossChainController);
    }
  }
}

contract Ethereum is DeployZkSyncAdapter {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function PROVIDER_GAS_LIMIT() internal view virtual override returns (uint256) {
    return 650_000;
  }

  function REFUND_ADDRESS() internal view override returns (address) {
    Addresses memory remoteAddresses = _getAddresses(ChainIds.ZKSYNC);
    return remoteAddresses.crossChainController;
  }

  function REMOTE_CCC_BY_NETWORK() internal pure override returns (RemoteCCC[] memory) {
    return new RemoteCCC[](0);
  }

  function BRIDGE_HUB() internal pure override returns (address) {
    return 0x303a465B659cBB0ab36eE643eA362c509EEb5213;
  }
}

contract Zksync is DeployZkSyncAdapter {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ZKSYNC;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;
    return remoteCCCByNetwork;
  }

  function BRIDGE_HUB() internal pure override returns (address) {
    return 0x303a465B659cBB0ab36eE643eA362c509EEb5213; // Set to mainnet address, but not used on zkSync
  }
}
