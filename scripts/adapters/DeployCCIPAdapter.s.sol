// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'adi-scripts/Adapters/DeployCCIP.sol';
import '../BaseDeployerScript.sol';

abstract contract DeployCCIPAdapter is BaseDeployerScript, BaseCCIPAdapter {
  function _execute(Addresses memory addresses) internal override {
    addresses.ccipAdapter = _deployAdapter(addresses.crossChainController);
  }
}

contract Ethereum is DeployCCIPAdapter {
  function CCIP_ROUTER() internal pure override returns (address) {
    return 0x80226fc0Ee2b096224EeAc085Bb9a8cba1146f7D;
  }

  function LINK_TOKEN() internal pure override returns (address) {
    return 0x514910771AF9Ca656af840dff83E8264EcF986CA;
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

contract Ethereum_testnet is DeployCCIPAdapter {
  function CCIP_ROUTER() internal pure override returns (address) {
    return 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
  }

  function LINK_TOKEN() internal pure override returns (address) {
    return 0x779877A7B0D9E8603169DdbD7836e478b4624789;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  function isTestnet() internal pure override returns (bool) {
    return true;
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
}

contract Avalanche is DeployCCIPAdapter {
  function CCIP_ROUTER() internal pure override returns (address) {
    return 0xF4c7E640EdA248ef95972845a62bdC74237805dB;
  }

  function LINK_TOKEN() internal pure override returns (address) {
    return 0x5947BB275c521040051D82396192181b413227A3;
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

contract Avalanche_testnet is DeployCCIPAdapter {
  function CCIP_ROUTER() internal pure override returns (address) {
    return 0xF694E193200268f9a4868e4Aa017A0118C9a8177;
  }

  function LINK_TOKEN() internal pure override returns (address) {
    return 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.AVALANCHE_FUJI;
  }

  function isTestnet() internal pure override returns (bool) {
    return true;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = TestNetChainIds.ETHEREUM_SEPOLIA;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(TestNetChainIds.ETHEREUM_SEPOLIA)
      .crossChainController;

    return remoteCCCByNetwork;
  }
}

contract Polygon is DeployCCIPAdapter {
  function CCIP_ROUTER() internal pure override returns (address) {
    return 0x849c5ED5a80F5B408Dd4969b78c2C8fdf0565Bfe;
  }

  function LINK_TOKEN() internal pure override returns (address) {
    return 0xb0897686c545045aFc77CF20eC7A532E3120E0F1;
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

contract Polygon_testnet is DeployCCIPAdapter {
  function CCIP_ROUTER() internal pure override returns (address) {
    return 0x1035CabC275068e0F4b745A29CEDf38E13aF41b1;
  }

  function LINK_TOKEN() internal pure override returns (address) {
    return 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.POLYGON_AMOY;
  }

  function isTestnet() internal pure override returns (bool) {
    return true;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = TestNetChainIds.ETHEREUM_SEPOLIA;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(TestNetChainIds.ETHEREUM_SEPOLIA)
      .crossChainController;

    return remoteCCCByNetwork;
  }
}

contract Binance is DeployCCIPAdapter {
  function CCIP_ROUTER() internal pure override returns (address) {
    return 0x34B03Cb9086d7D758AC55af71584F81A598759FE;
  }

  function LINK_TOKEN() internal pure override returns (address) {
    return 0x404460C6A5EdE2D891e8297795264fDe62ADBB75;
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

contract Binance_testnet is DeployCCIPAdapter {
  function CCIP_ROUTER() internal pure override returns (address) {
    return 0xE1053aE1857476f36A3C62580FF9b016E8EE8F6f;
  }

  function LINK_TOKEN() internal pure override returns (address) {
    return 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06;
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
}

contract Celo is DeployCCIPAdapter {
  function CCIP_ROUTER() internal pure override returns (address) {
    return 0xfB48f15480926A4ADf9116Dca468bDd2EE6C5F62;
  }

  function LINK_TOKEN() internal pure override returns (address) {
    return 0xd07294e6E917e07dfDcee882dd1e2565085C2ae0;
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

contract Sonic is DeployCCIPAdapter {
  function CCIP_ROUTER() internal pure override returns (address) {
    return 0xB4e1Ff7882474BB93042be9AD5E1fA387949B860;
  }

  function LINK_TOKEN() internal pure override returns (address) {
    return 0x71052BAe71C25C78E37fD12E5ff1101A71d9018F;
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

contract Plasma is DeployCCIPAdapter {
  function CCIP_ROUTER() internal pure override returns (address) {
    return 0xcDca5D374e46A6DDDab50bD2D9acB8c796eC35C3;
  }

  function LINK_TOKEN() internal pure override returns (address) {
    return 0x76a443768A5e3B8d1AED0105FC250877841Deb40;
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
