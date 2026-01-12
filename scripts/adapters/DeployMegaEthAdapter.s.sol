// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'adi-scripts/Adapters/DeployMegaEthAdapter.sol';
import '../BaseDeployerScript.sol';

abstract contract DeployMegaethAdapter is BaseDeployerScript, BaseMegaethAdapter {
  function _execute(Addresses memory addresses) internal override {
    addresses.megaethAdapter = _deployAdapter(addresses.crossChainController);
  }
}

contract Ethereum is DeployMegaethAdapter {
  function OVM() internal pure override returns (address) {
    return 0x6C7198250087B29A8040eC63903Bc130f4831Cc9;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_CCC_BY_NETWORK() internal pure override returns (RemoteCCC[] memory) {
    return new RemoteCCC[](0);
  }
}

contract Megaeth is DeployMegaethAdapter {
  function OVM() internal pure override returns (address) {
    return 0x4200000000000000000000000000000000000007;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.MEGAETH;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;

    return remoteCCCByNetwork;
  }
}
