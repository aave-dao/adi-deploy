// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'adi-scripts/Adapters/DeployInkAdapter.sol';
import '../BaseDeployerScript.sol';

abstract contract DeployInkAdapter is BaseDeployerScript, BaseInkAdapter {
  function _execute(Addresses memory addresses) internal override {
    addresses.inkAdapter = _deployAdapter(addresses.crossChainController);
  }
}

// @dev addresses taken from https://docs.inkonchain.com/useful-information/contracts
contract Ethereum is DeployInkAdapter {
  function OVM() internal pure override returns (address) {
    return 0x69d3Cf86B2Bf1a9e99875B7e2D9B6a84426c171f;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_CCC_BY_NETWORK() internal pure override returns (RemoteCCC[] memory) {
    return new RemoteCCC[](0);
  }
}

contract Ink is DeployInkAdapter {
  function OVM() internal pure override returns (address) {
    return 0x4200000000000000000000000000000000000007;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.INK;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;

    return remoteCCCByNetwork;
  }
}
