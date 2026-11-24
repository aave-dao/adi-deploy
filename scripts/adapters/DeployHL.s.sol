// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'adi-scripts/Adapters/DeployHL.sol';
import '../BaseDeployerScript.sol';
import {TempoPathConfig} from './TempoPathConfig.sol';

abstract contract DeployHLAdapter is BaseDeployerScript, BaseHLAdapter {
  function _execute(Addresses memory addresses) internal override {
    addresses.hlAdapter = _deployAdapter(addresses.crossChainController);
  }

  /// @dev creation code + constructor args, used to predict the CREATE2 address in tests
  function getAdapterCode() external view returns (bytes memory) {
    return _getAdapterByteCode(_getAddresses(TRANSACTION_NETWORK()).crossChainController);
  }
}

contract Ethereum is DeployHLAdapter {
  function HL_MAIL_BOX() internal pure override returns (address) {
    return 0xc005dc82818d67AF737725bD4bf75435d065D239;
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

contract Avalanche is DeployHLAdapter {
  function HL_MAIL_BOX() internal pure override returns (address) {
    return 0xFf06aFcaABaDDd1fb08371f9ccA15D73D51FeBD6;
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

contract Polygon is DeployHLAdapter {
  function HL_MAIL_BOX() internal pure override returns (address) {
    return 0x5d934f4e2f797775e53561bB72aca21ba36B96BB;
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

contract Binance is DeployHLAdapter {
  function HL_MAIL_BOX() internal pure override returns (address) {
    return 0x2971b9Aec44bE4eb673DF1B88cDB57b96eefe8a4;
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

contract Gnosis is DeployHLAdapter {
  function HL_MAIL_BOX() internal pure override returns (address) {
    return 0xaD09d78f4c6b9dA2Ae82b1D34107802d380Bb74f;
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

contract Celo is DeployHLAdapter {
  function HL_MAIL_BOX() internal pure override returns (address) {
    return 0x50da3B3907A08a24fe4999F4Dcf337E8dC7954bb;
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

contract Sonic is DeployHLAdapter {
  function HL_MAIL_BOX() internal pure override returns (address) {
    return 0x3a464f746D23Ab22155710f44dB16dcA53e0775E;
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

contract Plasma is DeployHLAdapter {
  function HL_MAIL_BOX() internal pure override returns (address) {
    return 0x3a464f746D23Ab22155710f44dB16dcA53e0775E;
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

contract Monad is DeployHLAdapter {
  function HL_MAIL_BOX() internal pure override returns (address) {
    return 0x3a464f746D23Ab22155710f44dB16dcA53e0775E;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.MONAD;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;

    return remoteCCCByNetwork;
  }
}

contract Tempo is DeployHLAdapter {
  function HL_MAIL_BOX() internal pure override returns (address) {
    return 0x3a867fCfFeC2B790970eeBDC9023E75B0a172aa7;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.TEMPO;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;

    return remoteCCCByNetwork;
  }
}

/// @dev Ethereum adapter for the Tempo path, with a higher base gas limit for delivery on Tempo
contract Ethereum_Tempo is DeployHLAdapter {
  function HL_MAIL_BOX() internal pure override returns (address) {
    return 0xc005dc82818d67AF737725bD4bf75435d065D239;
  }

  /// @dev Tempo CrossChainController, from deployments/tempo.json
  function TEMPO_CCC() internal view virtual returns (address) {
    return _getAddresses(ChainIds.TEMPO).crossChainController;
  }

  function PROVIDER_GAS_LIMIT() internal pure override returns (uint256) {
    return TempoPathConfig.ETHEREUM_PROVIDER_GAS_LIMIT;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.TEMPO;
    remoteCCCByNetwork[0].crossChainController = TEMPO_CCC();

    return remoteCCCByNetwork;
  }
}
