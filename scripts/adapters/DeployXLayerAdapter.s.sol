// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'adi-scripts/Adapters/DeployXLayer.sol';
import '../BaseDeployerScript.sol';

abstract contract DeployXLayerAdapter is BaseDeployerScript, BaseXLayerAdapter {
  function _execute(Addresses memory addresses) internal override {
    addresses.xlayerAdapter = _deployAdapter(addresses.crossChainController);
  }
}

// @dev addresses taken from TODO: add link to docs
contract Ethereum is DeployXLayerAdapter {
  function OVM() internal pure override returns (address) {
    return address(0); // TODO: add address when deployed
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_CCC_BY_NETWORK() internal pure override returns (RemoteCCC[] memory) {
    return new RemoteCCC[](0);
  }
}

contract Xlayer is DeployXLayerAdapter {
  function OVM() internal pure override returns (address) {
    return 0x4200000000000000000000000000000000000007;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.XLAYER;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;

    return remoteCCCByNetwork;
  }
}
