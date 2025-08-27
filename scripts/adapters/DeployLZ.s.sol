// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'adi-scripts/Adapters/DeployLZ.sol';
import '../BaseDeployerScript.sol';

abstract contract DeployLZAdapter is BaseDeployerScript, BaseLZAdapter {
  function _execute(Addresses memory addresses) internal override {
    addresses.lzAdapter = _deployAdapter(addresses.crossChainController);
  }
}

contract Ethereum is DeployLZAdapter {
  function LZ_ENDPOINT() internal pure override returns (address) {
    return 0x1a44076050125825900e736c501f859c50fE728c;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](2);
    remoteCCCByNetwork[0].chainId = ChainIds.POLYGON;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.POLYGON)
      .crossChainController;

    remoteCCCByNetwork[1].chainId = ChainIds.AVALANCHE;
    remoteCCCByNetwork[1].crossChainController = _getAddresses(ChainIds.AVALANCHE)
      .crossChainController;

    return remoteCCCByNetwork;
  }
}

contract Ethereum_testnet is DeployLZAdapter {
  function LZ_ENDPOINT() internal pure override returns (address) {
    return 0x6EDCE65403992e310A62460808c4b910D972f10f;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](2);
    remoteCCCByNetwork[0].chainId = TestNetChainIds.POLYGON_AMOY;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(TestNetChainIds.POLYGON_AMOY)
      .crossChainController;

    remoteCCCByNetwork[1].chainId = TestNetChainIds.AVALANCHE_FUJI;
    remoteCCCByNetwork[1].crossChainController = _getAddresses(TestNetChainIds.AVALANCHE_FUJI)
      .crossChainController;

    return remoteCCCByNetwork;
  }

  function isTestnet() internal pure override returns (bool) {
    return true;
  }
}

contract Avalanche is DeployLZAdapter {
  function LZ_ENDPOINT() internal pure override returns (address) {
    return 0x1a44076050125825900e736c501f859c50fE728c;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.AVALANCHE;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;

    return remoteCCCByNetwork;
  }
}

contract Avalanche_testnet is DeployLZAdapter {
  function LZ_ENDPOINT() internal pure override returns (address) {
    return 0x6EDCE65403992e310A62460808c4b910D972f10f;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.AVALANCHE_FUJI;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = TestNetChainIds.ETHEREUM_SEPOLIA;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(TestNetChainIds.ETHEREUM_SEPOLIA)
      .crossChainController;

    return remoteCCCByNetwork;
  }

  function isTestnet() internal pure override returns (bool) {
    return true;
  }
}

contract Polygon is DeployLZAdapter {
  function LZ_ENDPOINT() internal pure override returns (address) {
    return 0x1a44076050125825900e736c501f859c50fE728c;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.POLYGON;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;

    return remoteCCCByNetwork;
  }
}

contract Polygon_testnet is DeployLZAdapter {
  function LZ_ENDPOINT() internal pure override returns (address) {
    return 0x6EDCE65403992e310A62460808c4b910D972f10f;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.POLYGON_AMOY;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = TestNetChainIds.ETHEREUM_SEPOLIA;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(TestNetChainIds.ETHEREUM_SEPOLIA)
      .crossChainController;

    return remoteCCCByNetwork;
  }

  function isTestnet() internal pure override returns (bool) {
    return true;
  }
}

contract Binance is DeployLZAdapter {
  function LZ_ENDPOINT() internal pure override returns (address) {
    return 0x1a44076050125825900e736c501f859c50fE728c;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.BNB;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;

    return remoteCCCByNetwork;
  }
}

contract Binance_testnet is DeployLZAdapter {
  function LZ_ENDPOINT() internal pure override returns (address) {
    return 0x6EDCE65403992e310A62460808c4b910D972f10f;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.BNB_TESTNET;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = TestNetChainIds.ETHEREUM_SEPOLIA;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(TestNetChainIds.ETHEREUM_SEPOLIA)
      .crossChainController;

    return remoteCCCByNetwork;
  }

  function isTestnet() internal pure override returns (bool) {
    return true;
  }
}

contract Gnosis is DeployLZAdapter {
  function LZ_ENDPOINT() internal pure override returns (address) {
    return 0x1a44076050125825900e736c501f859c50fE728c;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.GNOSIS;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;

    return remoteCCCByNetwork;
  }
}

contract Gnosis_testnet is DeployLZAdapter {
  function LZ_ENDPOINT() internal pure override returns (address) {
    return 0x6EDCE65403992e310A62460808c4b910D972f10f;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.GNOSIS_CHIADO;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = TestNetChainIds.ETHEREUM_SEPOLIA;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(TestNetChainIds.ETHEREUM_SEPOLIA)
      .crossChainController;

    return remoteCCCByNetwork;
  }

  function isTestnet() internal pure override returns (bool) {
    return true;
  }
}

contract Celo is DeployLZAdapter {
  function LZ_ENDPOINT() internal pure override returns (address) {
    return 0x1a44076050125825900e736c501f859c50fE728c;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.CELO;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;

    return remoteCCCByNetwork;
  }
}

contract Celo_testnet is DeployLZAdapter {
  function LZ_ENDPOINT() internal pure override returns (address) {
    return 0x6EDCE65403992e310A62460808c4b910D972f10f;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.CELO_ALFAJORES;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = TestNetChainIds.ETHEREUM_SEPOLIA;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(TestNetChainIds.ETHEREUM_SEPOLIA)
      .crossChainController;

    return remoteCCCByNetwork;
  }

  function isTestnet() internal pure override returns (bool) {
    return true;
  }
}

contract Sonic is DeployLZAdapter {
  function LZ_ENDPOINT() internal pure override returns (address) {
    return 0x6F475642a6e85809B1c36Fa62763669b1b48DD5B;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.SONIC;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;

    return remoteCCCByNetwork;
  }
}

// TODO: add plasma adapter
contract Plasma is DeployLZAdapter {
  function LZ_ENDPOINT() internal pure override returns (address) {
    return address(0);
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.PLASMA;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;

    return remoteCCCByNetwork;
  }
}
