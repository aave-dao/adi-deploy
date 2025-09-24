// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'adi-scripts/Adapters/DeployArbAdapter.sol';
import '../BaseDeployerScript.sol';

abstract contract DeployArbAdapter is BaseDeployerScript, BaseDeployArbAdapter {
  function _execute(Addresses memory addresses) internal virtual override {
    addresses.arbAdapter = _deployAdapter(addresses.crossChainController);
  }
}

contract Ethereum is DeployArbAdapter {
  function INBOX() internal pure override returns (address) {
    return 0x4Dbd4fc535Ac27206064B68FfCf827b0A60BAB3f;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_CCC_BY_NETWORK() internal pure override returns (RemoteCCC[] memory) {
    return new RemoteCCC[](0);
  }

  function REFUND_ADDRESS() internal view override returns (address) {
    return _getAddresses(ChainIds.ARBITRUM).crossChainController;
  }
}

contract Arbitrum is DeployArbAdapter {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ARBITRUM;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;
    return remoteCCCByNetwork;
  }
}
