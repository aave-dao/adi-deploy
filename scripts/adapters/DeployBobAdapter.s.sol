// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'adi-scripts/Adapters/DeployBobAdapter.sol';
import '../BaseDeployerScript.sol';

abstract contract DeployBobAdapter is BaseDeployerScript, BaseBobAdapter {
  function _execute(Addresses memory addresses) internal override {
    addresses.bobAdapter = _deployAdapter(addresses.crossChainController);
  }
}

// @dev addresses taken from https://docs.gobob.xyz/learn/reference/contracts/
contract Ethereum is DeployBobAdapter {
  function OVM() internal pure override returns (address) {
    return 0xE3d981643b806FB8030CDB677D6E60892E547EdA;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_CCC_BY_NETWORK() internal pure override returns (RemoteCCC[] memory) {
    return new RemoteCCC[](0);
  }
}

contract Bob is DeployBobAdapter {
  function OVM() internal pure override returns (address) {
    return 0x4200000000000000000000000000000000000007;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.BOB;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;

    return remoteCCCByNetwork;
  }
}
