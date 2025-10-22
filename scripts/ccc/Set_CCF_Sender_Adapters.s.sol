// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ICrossChainForwarder} from 'adi/interfaces/ICrossChainForwarder.sol';
import '../BaseDeployerScript.sol';

struct NetworkAddresses {
  Addresses polygon;
  Addresses avalanche;
  Addresses binance;
  Addresses optimism;
  Addresses arbitrum;
  Addresses metis;
  Addresses base;
  Addresses gnosis;
  Addresses scroll;
  Addresses celo;
  Addresses zksync;
  Addresses linea;
  Addresses mantle;
  Addresses sonic;
  Addresses ink;
  Addresses soneium;
  Addresses bob;
  Addresses plasma;
  Addresses xlayer;
}

abstract contract BaseCCFSenderAdapters is BaseDeployerScript {
  function getBridgeAdaptersToEnable(
    Addresses memory addresses
  ) public view virtual returns (ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[] memory);

  function _execute(Addresses memory addresses) internal override {
    ICrossChainForwarder(addresses.crossChainController).enableBridgeAdapters(
      getBridgeAdaptersToEnable(addresses)
    );
  }
}

contract Ethereum is BaseCCFSenderAdapters {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function getBridgeAdaptersToEnable(
    Addresses memory addresses
  ) public view override returns (ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[] memory) {
    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[]
      memory bridgeAdaptersToEnable = new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](
        1
      );

    NetworkAddresses memory networkAddresses = NetworkAddresses({
      polygon: _getAddresses(ChainIds.POLYGON),
      avalanche: _getAddresses(ChainIds.AVALANCHE),
      binance: _getAddresses(ChainIds.BNB),
      optimism: _getAddresses(ChainIds.OPTIMISM),
      arbitrum: _getAddresses(ChainIds.ARBITRUM),
      metis: _getAddresses(ChainIds.METIS),
      base: _getAddresses(ChainIds.BASE),
      gnosis: _getAddresses(ChainIds.GNOSIS),
      scroll: _getAddresses(ChainIds.SCROLL),
      celo: _getAddresses(ChainIds.CELO),
      zksync: _getAddresses(ChainIds.ZKSYNC),
      linea: _getAddresses(ChainIds.LINEA),
      sonic: _getAddresses(ChainIds.SONIC),
      mantle: _getAddresses(ChainIds.MANTLE),
      ink: _getAddresses(ChainIds.INK),
      soneium: _getAddresses(ChainIds.SONEIUM),
      bob: _getAddresses(ChainIds.BOB),
      plasma: _getAddresses(ChainIds.PLASMA),
      xlayer: _getAddresses(ChainIds.XLAYER)
    });

    // polygon path
    // bridgeAdaptersToEnable[0] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.polAdapter,
    //   destinationBridgeAdapter: networkAddresses.polygon.polAdapter,
    //   destinationChainId: networkAddresses.polygon.chainId
    // });
    // bridgeAdaptersToEnable[1] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.ccipAdapter,
    //   destinationBridgeAdapter: networkAddresses.polygon.ccipAdapter,
    //   destinationChainId: networkAddresses.polygon.chainId
    // });
    // bridgeAdaptersToEnable[2] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.lzAdapter,
    //   destinationBridgeAdapter: networkAddresses.polygon.lzAdapter,
    //   destinationChainId: networkAddresses.polygon.chainId
    // });
    // bridgeAdaptersToEnable[3] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.hlAdapter,
    //   destinationBridgeAdapter: networkAddresses.polygon.hlAdapter,
    //   destinationChainId: networkAddresses.polygon.chainId
    // });

    // // avalanche path
    // bridgeAdaptersToEnable[4] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.ccipAdapter,
    //   destinationBridgeAdapter: networkAddresses.avalanche.ccipAdapter,
    //   destinationChainId: networkAddresses.avalanche.chainId
    // });
    // bridgeAdaptersToEnable[5] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.lzAdapter,
    //   destinationBridgeAdapter: networkAddresses.avalanche.lzAdapter,
    //   destinationChainId: networkAddresses.avalanche.chainId
    // });
    // bridgeAdaptersToEnable[6] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.hlAdapter,
    //   destinationBridgeAdapter: networkAddresses.avalanche.hlAdapter,
    //   destinationChainId: networkAddresses.avalanche.chainId
    // });

    // // binance path
    // bridgeAdaptersToEnable[7] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.lzAdapter,
    //   destinationBridgeAdapter: networkAddresses.binance.lzAdapter,
    //   destinationChainId: networkAddresses.binance.chainId
    // });
    // bridgeAdaptersToEnable[8] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.hlAdapter,
    //   destinationBridgeAdapter: networkAddresses.binance.hlAdapter,
    //   destinationChainId: networkAddresses.binance.chainId
    // });
    // bridgeAdaptersToEnable[9] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.ccipAdapter,
    //   destinationBridgeAdapter: networkAddresses.binance.ccipAdapter,
    //   destinationChainId: networkAddresses.binance.chainId
    // });

    // // optimism
    // bridgeAdaptersToEnable[10] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.opAdapter,
    //   destinationBridgeAdapter: networkAddresses.optimism.opAdapter,
    //   destinationChainId: networkAddresses.optimism.chainId
    // });
    // // arbitrum
    // bridgeAdaptersToEnable[11] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.arbAdapter,
    //   destinationBridgeAdapter: networkAddresses.arbitrum.arbAdapter,
    //   destinationChainId: networkAddresses.arbitrum.chainId
    // });
    // // metis
    // bridgeAdaptersToEnable[12] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.metisAdapter,
    //   destinationBridgeAdapter: networkAddresses.metis.metisAdapter,
    //   destinationChainId: networkAddresses.metis.chainId
    // });
    // //base
    // bridgeAdaptersToEnable[13] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.baseAdapter,
    //   destinationBridgeAdapter: networkAddresses.base.baseAdapter,
    //   destinationChainId: networkAddresses.base.chainId
    // });

    // // same chain path
    // bridgeAdaptersToEnable[14] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.sameChainAdapter,
    //   destinationBridgeAdapter: addresses.sameChainAdapter,
    //   destinationChainId: addresses.chainId
    // });

    // // gnosis
    // bridgeAdaptersToEnable[15] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.gnosisAdapter,
    //   destinationBridgeAdapter: networkAddresses.gnosis.gnosisAdapter,
    //   destinationChainId: networkAddresses.gnosis.chainId
    // });
    // bridgeAdaptersToEnable[16] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.lzAdapter,
    //   destinationBridgeAdapter: networkAddresses.gnosis.lzAdapter,
    //   destinationChainId: networkAddresses.gnosis.chainId
    // });
    // bridgeAdaptersToEnable[17] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.hlAdapter,
    //   destinationBridgeAdapter: networkAddresses.gnosis.hlAdapter,
    //   destinationChainId: networkAddresses.gnosis.chainId
    // });

    // // Scroll
    // bridgeAdaptersToEnable[19] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.scrollAdapter,
    //   destinationBridgeAdapter: networkAddresses.scroll.scrollAdapter,
    //   destinationChainId: networkAddresses.scroll.chainId
    // });

    // // Celo
    // bridgeAdaptersToEnable[20] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.wormholeAdapter,
    //   destinationBridgeAdapter: networkAddresses.celo.wormholeAdapter,
    //   destinationChainId: networkAddresses.celo.chainId
    // });
    // bridgeAdaptersToEnable[21] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.lzAdapter,
    //   destinationBridgeAdapter: networkAddresses.celo.lzAdapter,
    //   destinationChainId: networkAddresses.celo.chainId
    // });
    // bridgeAdaptersToEnable[22] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.hlAdapter,
    //   destinationBridgeAdapter: networkAddresses.celo.hlAdapter,
    //   destinationChainId: networkAddresses.celo.chainId
    // });

    // // ZkSync
    // bridgeAdaptersToEnable[23] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.zksyncAdapter,
    //   destinationBridgeAdapter: networkAddresses.zksync.zksyncAdapter,
    //   destinationChainId: networkAddresses.zksync.chainId
    // });

    // // Linea
    // bridgeAdaptersToEnable[24] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.lineaAdapter,
    //   destinationBridgeAdapter: networkAddresses.linea.lineaAdapter,
    //   destinationChainId: networkAddresses.linea.chainId
    // });

    // // Sonic
    // bridgeAdaptersToEnable[25] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.ccipAdapter,
    //   destinationBridgeAdapter: networkAddresses.sonic.ccipAdapter,
    //   destinationChainId: networkAddresses.sonic.chainId
    // });
    // bridgeAdaptersToEnable[26] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.lzAdapter,
    //   destinationBridgeAdapter: networkAddresses.celo.lzAdapter,
    //   destinationChainId: networkAddresses.celo.chainId
    // });
    // bridgeAdaptersToEnable[27] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.hlAdapter,
    //   destinationBridgeAdapter: networkAddresses.celo.hlAdapter,
    //   destinationChainId: networkAddresses.celo.chainId
    // });

    // // Mantle
    // bridgeAdaptersToEnable[28] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.mantleAdapter,
    //   destinationBridgeAdapter: networkAddresses.mantle.mantleAdapter,
    //   destinationChainId: networkAddresses.mantle.chainId
    // });

    // // Ink
    // bridgeAdaptersToEnable[29] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.inkAdapter,
    //   destinationBridgeAdapter: networkAddresses.ink.inkAdapter,
    //   destinationChainId: networkAddresses.ink.chainId
    // });

    // Soneium
    // bridgeAdaptersToEnable[0] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.soneiumAdapter,
    //   destinationBridgeAdapter: networkAddresses.soneium.soneiumAdapter,
    //   destinationChainId: networkAddresses.soneium.chainId
    // });

    // Bob
    // bridgeAdaptersToEnable[0] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.bobAdapter,
    //   destinationBridgeAdapter: networkAddresses.bob.bobAdapter,
    //   destinationChainId: networkAddresses.bob.chainId
    // });

    // Plasma
    // bridgeAdaptersToEnable[0] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.ccipAdapter,
    //   destinationBridgeAdapter: networkAddresses.plasma.ccipAdapter,
    //   destinationChainId: networkAddresses.plasma.chainId
    // });
    // bridgeAdaptersToEnable[1] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.lzAdapter,
    //   destinationBridgeAdapter: networkAddresses.plasma.lzAdapter,
    //   destinationChainId: networkAddresses.plasma.chainId
    // });
    // bridgeAdaptersToEnable[2] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
    //   currentChainBridgeAdapter: addresses.hlAdapter,
    //   destinationBridgeAdapter: networkAddresses.plasma.hlAdapter,
    //   destinationChainId: networkAddresses.plasma.chainId
    // });

    // XLayer
    bridgeAdaptersToEnable[0] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
      currentChainBridgeAdapter: addresses.xlayerAdapter,
      destinationBridgeAdapter: networkAddresses.xlayer.xlayerAdapter,
      destinationChainId: networkAddresses.xlayer.chainId
    });

    return bridgeAdaptersToEnable;
  }
}

contract Polygon is BaseCCFSenderAdapters {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.POLYGON;
  }

  function getBridgeAdaptersToEnable(
    Addresses memory addresses
  ) public view override returns (ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[] memory) {
    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[]
      memory bridgeAdaptersToEnable = new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](
        4
      );

    // ethereum path
    Addresses memory ethereumAddresses = _getAddresses(ChainIds.ETHEREUM);

    bridgeAdaptersToEnable[0] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
      currentChainBridgeAdapter: addresses.ccipAdapter,
      destinationBridgeAdapter: ethereumAddresses.ccipAdapter,
      destinationChainId: ethereumAddresses.chainId
    });
    bridgeAdaptersToEnable[1] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
      currentChainBridgeAdapter: addresses.lzAdapter,
      destinationBridgeAdapter: ethereumAddresses.lzAdapter,
      destinationChainId: ethereumAddresses.chainId
    });
    bridgeAdaptersToEnable[2] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
      currentChainBridgeAdapter: addresses.hlAdapter,
      destinationBridgeAdapter: ethereumAddresses.hlAdapter,
      destinationChainId: ethereumAddresses.chainId
    });
    bridgeAdaptersToEnable[3] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
      currentChainBridgeAdapter: addresses.polAdapter,
      destinationBridgeAdapter: ethereumAddresses.polAdapter,
      destinationChainId: ethereumAddresses.chainId
    });
    return bridgeAdaptersToEnable;
  }
}

contract Avalanche is BaseCCFSenderAdapters {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.AVALANCHE;
  }

  function getBridgeAdaptersToEnable(
    Addresses memory addresses
  ) public view override returns (ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[] memory) {
    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[]
      memory bridgeAdaptersToEnable = new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](
        3
      );

    // ethereum path
    Addresses memory ethereumAddresses = _getAddresses(ChainIds.ETHEREUM);

    bridgeAdaptersToEnable[0] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
      currentChainBridgeAdapter: addresses.ccipAdapter,
      destinationBridgeAdapter: ethereumAddresses.ccipAdapter,
      destinationChainId: ethereumAddresses.chainId
    });
    bridgeAdaptersToEnable[1] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
      currentChainBridgeAdapter: addresses.lzAdapter,
      destinationBridgeAdapter: ethereumAddresses.lzAdapter,
      destinationChainId: ethereumAddresses.chainId
    });
    bridgeAdaptersToEnable[2] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
      currentChainBridgeAdapter: addresses.hlAdapter,
      destinationBridgeAdapter: ethereumAddresses.hlAdapter,
      destinationChainId: ethereumAddresses.chainId
    });

    return bridgeAdaptersToEnable;
  }
}
