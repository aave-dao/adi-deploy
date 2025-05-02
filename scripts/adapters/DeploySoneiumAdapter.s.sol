// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'adi-scripts/Adapters/DeploySoneiumAdapter.sol';
import '../BaseDeployerScript.sol';

abstract contract DeploySoneiumAdapter is BaseDeployerScript, BaseSoneiumAdapter {
  function _execute(Addresses memory addresses) internal override {
    addresses.soneiumAdapter = _deployAdapter(addresses.crossChainController);
  }
}

// @dev addresses taken from https://docs.inkonchain.com/useful-information/contracts
contract Ethereum is DeploySoneiumAdapter {
  function OVM() internal pure override returns (address) {
    return 0x9CF951E3F74B644e621b36Ca9cea147a78D4c39f;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_CCC_BY_NETWORK() internal pure override returns (RemoteCCC[] memory) {
    return new RemoteCCC[](0);
  }
}

contract Soneium is DeploySoneiumAdapter {
  function OVM() internal pure override returns (address) {
    return 0x4200000000000000000000000000000000000007;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.SONEIUM;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;

    return remoteCCCByNetwork;
  }
}
