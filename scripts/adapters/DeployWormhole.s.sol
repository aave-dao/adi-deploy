// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'adi-scripts/Adapters/DeployWormholeAdapter.sol';
import '../BaseDeployerScript.sol';

abstract contract DeployWormholeAdapter is BaseDeployerScript, BaseWormholeAdapter {
  function _execute(Addresses memory addresses) internal override {
    addresses.wormholeAdapter = _deployAdapter(addresses.crossChainController);
  }
}

contract Ethereum is DeployWormholeAdapter {
  function WORMHOLE_RELAYER() internal pure override returns (address) {
    return 0x27428DD2d3DD32A4D7f7C497eAaa23130d894911;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REFUND_ADDRESS() internal view override returns (address) {
    Addresses memory destinationAddresses = _getAddresses(ChainIds.CELO);
    return destinationAddresses.crossChainController;
  }

  function REMOTE_CCC_BY_NETWORK() internal pure override returns (RemoteCCC[] memory) {
    return new RemoteCCC[](0);
  }
}

contract Celo is DeployWormholeAdapter {
  function WORMHOLE_RELAYER() internal pure override returns (address) {
    return 0x27428DD2d3DD32A4D7f7C497eAaa23130d894911;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.CELO;
  }

  function REFUND_ADDRESS() internal pure override returns (address) {
    return address(0);
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;
    return remoteCCCByNetwork;
  }
}
