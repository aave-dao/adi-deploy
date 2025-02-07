// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'adi-scripts/Adapters/DeployMantleAdapter.sol';
import '../BaseDeployerScript.sol';

abstract contract DeployMantleAdapter is BaseDeployerScript, BaseMantleAdapter {
  function _execute(Addresses memory addresses) internal override {
    addresses.mantleAdapter = _deployAdapter(addresses.crossChainController);
  }
}

contract Ethereum is DeployMantleAdapter {
  function OVM() internal pure override returns (address) {
    return 0x676A795fe6E43C17c668de16730c3F690FEB7120;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_CCC_BY_NETWORK() internal pure override returns (RemoteCCC[] memory) {
    return new RemoteCCC[](0);
  }
}

contract Mantle is DeployMantleAdapter {
  function OVM() internal pure override returns (address) {
    return 0x4200000000000000000000000000000000000007;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.MANTLE;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;

    return remoteCCCByNetwork;
  }
}

// contract Ethereum_testnet is DeployMantleAdapter {
//   function OVM() internal pure override returns (address) {
//     return 0x866E82a600A1414e583f7F13623F1aC5d58b0Afa;
//   }

//   function TRANSACTION_NETWORK() internal pure override returns (uint256) {
//     return TestNetChainIds.ETHEREUM_SEPOLIA;
//   }
  
//   function isTestnet() internal pure override returns (bool) {
//     return true;
//   }

//   function REMOTE_CCC_BY_NETWORK() internal pure override returns (RemoteCCC[] memory) {
//     return new RemoteCCC[](0);
//   }
// }

// contract Mantle_testnet is DeployMantleAdapter {
//   function OVM() internal pure override returns (address) {
//     return 0x4200000000000000000000000000000000000007;
//   }

//   function TRANSACTION_NETWORK() internal pure override returns (uint256) {
//     return TestNetChainIds.MANTLE_TESTNET;
//   }

//   function isTestnet() internal pure override returns (bool) {
//     return true;
//   }

//   function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
//     RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
//     remoteCCCByNetwork[0].chainId = TestNetChainIds.ETHEREUM_SEPOLIA;
//     remoteCCCByNetwork[0].crossChainController = _getAddresses(TestNetChainIds.ETHEREUM_SEPOLIA)
//       .crossChainController;

//     return remoteCCCByNetwork;
//   }
// }