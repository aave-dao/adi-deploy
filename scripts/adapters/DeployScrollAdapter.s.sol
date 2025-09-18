// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'adi-scripts/Adapters/DeployScrollAdapter.sol';
import '../BaseDeployerScript.sol';

abstract contract DeployScrollAdapter is BaseDeployerScript, BaseScrollAdapter {
  function _execute(Addresses memory addresses) internal override {
    addresses.scrollAdapter = _deployAdapter(addresses.crossChainController);
  }
}

contract Ethereum is DeployScrollAdapter {
  function OVM() internal pure override returns (address) {
    return 0x6774Bcbd5ceCeF1336b5300fb5186a12DDD8b367;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_CCC_BY_NETWORK() internal pure override returns (RemoteCCC[] memory) {
    return new RemoteCCC[](0);
  }
}

contract Scroll is DeployScrollAdapter {
  function OVM() internal pure override returns (address) {
    return 0x781e90f1c8Fc4611c9b7497C3B47F99Ef6969CbC;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.SCROLL;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;
    return remoteCCCByNetwork;
  }
}
