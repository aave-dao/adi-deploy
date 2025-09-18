// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'adi-scripts/Adapters/DeploySameChainAdapter.sol';
import '../BaseDeployerScript.sol';

abstract contract DeploySameChainAdapter is BaseDeployerScript, BaseSameChainAdapter {
  function _execute(Addresses memory addresses) internal override {
    addresses.sameChainAdapter = _deployAdapter(
      addresses.crossChainController
    );
  }
}

contract Ethereum is DeploySameChainAdapter {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_CCC_BY_NETWORK() internal pure override returns (RemoteCCC[] memory) {
    return new RemoteCCC[](0);
  }
}
