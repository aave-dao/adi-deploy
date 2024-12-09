// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'adi-scripts/Adapters/DeployLineaAdapter.sol';
import '../BaseDeployerScript.sol';

abstract contract DeployLineaAdapter is BaseDeployerScript, BaseDeployLineaAdapter {
  function _execute(Addresses memory addresses) internal override {
    addresses.lineaAdapter = _deployAdapter(addresses.crossChainController);
  }
}

contract Ethereum is DeployLineaAdapter {
  function LINEA_MESSAGE_SERVICE() internal pure override returns (address) {
    return 0xd19d4B5d358258f05D7B411E21A1460D11B0876F;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_CCC_BY_NETWORK() internal pure override returns (RemoteCCC[] memory) {
    return new RemoteCCC[](0);
  }
}

contract Linea is DeployLineaAdapter {
  function LINEA_MESSAGE_SERVICE() internal pure override returns (address) {
    return 0x508Ca82Df566dCD1B0DE8296e70a96332cD644ec;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.LINEA;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;
    return remoteCCCByNetwork;
  }
}

contract Ethereum_testnet is DeployLineaAdapter {
  function LINEA_MESSAGE_SERVICE() internal pure override returns (address) {
    return 0xB218f8A4Bc926cF1cA7b3423c154a0D627Bdb7E5;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  function REMOTE_CCC_BY_NETWORK() internal pure override returns (RemoteCCC[] memory) {
    return new RemoteCCC[](0);
  }
}

contract Linea_testnet is DeployLineaAdapter {
  function LINEA_MESSAGE_SERVICE() internal pure override returns (address) {
    return 0x971e727e956690b9957be6d51Ec16E73AcAC83A7;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.LINEA_SEPOLIA;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = TestNetChainIds.ETHEREUM_SEPOLIA;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(TestNetChainIds.ETHEREUM_SEPOLIA)
      .crossChainController;
    return remoteCCCByNetwork;
  }
}
