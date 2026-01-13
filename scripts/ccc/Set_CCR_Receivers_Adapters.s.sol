// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseDeployerScript.sol';
import {ICrossChainReceiver} from 'adi/interfaces/ICrossChainReceiver.sol';

abstract contract BaseSetCCRAdapters is BaseDeployerScript {
  function getChainIds() public virtual returns (uint256[] memory);

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public view virtual returns (address[] memory);

  function _execute(Addresses memory addresses) internal override {
    uint256[] memory chainIds = getChainIds();
    address[] memory receiverBridgeAdaptersToAllow = getReceiverBridgeAdaptersToAllow(addresses);

    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory bridgeAdapterConfig = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](
        receiverBridgeAdaptersToAllow.length
      );
    for (uint256 i = 0; i < receiverBridgeAdaptersToAllow.length; i++) {
      bridgeAdapterConfig[i] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
        bridgeAdapter: receiverBridgeAdaptersToAllow[i],
        chainIds: chainIds
      });
    }

    ICrossChainReceiver(addresses.crossChainController).allowReceiverBridgeAdapters(
      bridgeAdapterConfig
    );
  }
}

contract Ethereum is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](2);
    chainIds[0] = ChainIds.POLYGON;
    chainIds[1] = ChainIds.AVALANCHE;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure virtual override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](4);
    receiverBridgeAdaptersToAllow[0] = addresses.ccipAdapter;
    receiverBridgeAdaptersToAllow[1] = addresses.lzAdapter;
    receiverBridgeAdaptersToAllow[2] = addresses.hlAdapter;
    receiverBridgeAdaptersToAllow[3] = addresses.polAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Polygon is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.POLYGON;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure virtual override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](4);
    receiverBridgeAdaptersToAllow[0] = addresses.ccipAdapter;
    receiverBridgeAdaptersToAllow[1] = addresses.lzAdapter;
    receiverBridgeAdaptersToAllow[2] = addresses.hlAdapter;
    receiverBridgeAdaptersToAllow[3] = addresses.polAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Avalanche is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.AVALANCHE;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure virtual override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](3);
    receiverBridgeAdaptersToAllow[0] = addresses.ccipAdapter;
    receiverBridgeAdaptersToAllow[1] = addresses.lzAdapter;
    receiverBridgeAdaptersToAllow[2] = addresses.hlAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Optimism is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.OPTIMISM;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.opAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Arbitrum is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.ARBITRUM;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.arbAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Metis is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.METIS;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.metisAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Binance is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.BNB;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](3);
    receiverBridgeAdaptersToAllow[0] = addresses.lzAdapter;
    receiverBridgeAdaptersToAllow[1] = addresses.hlAdapter;
    receiverBridgeAdaptersToAllow[2] = addresses.ccipAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Base is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.BASE;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.baseAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Gnosis is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.GNOSIS;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](4);
    receiverBridgeAdaptersToAllow[0] = addresses.lzAdapter;
    receiverBridgeAdaptersToAllow[1] = addresses.hlAdapter;
    receiverBridgeAdaptersToAllow[2] = addresses.gnosisAdapter;
    receiverBridgeAdaptersToAllow[3] = addresses.ccipAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Scroll is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.SCROLL;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.scrollAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Celo is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.CELO;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](3);
    receiverBridgeAdaptersToAllow[0] = addresses.lzAdapter;
    receiverBridgeAdaptersToAllow[1] = addresses.hlAdapter;
    receiverBridgeAdaptersToAllow[2] = addresses.ccipAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Zksync is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.ZKSYNC;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.zksyncAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Linea is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.LINEA;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.lineaAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Mantle is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.MANTLE;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.mantleAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Sonic is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.SONIC;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](3);
    receiverBridgeAdaptersToAllow[0] = addresses.lzAdapter;
    receiverBridgeAdaptersToAllow[1] = addresses.hlAdapter;
    receiverBridgeAdaptersToAllow[2] = addresses.ccipAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Ink is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.INK;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.inkAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Soneium is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.SONEIUM;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.soneiumAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Bob is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.BOB;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.bobAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Plasma is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.PLASMA;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](3);
    receiverBridgeAdaptersToAllow[0] = addresses.lzAdapter;
    receiverBridgeAdaptersToAllow[1] = addresses.hlAdapter;
    receiverBridgeAdaptersToAllow[2] = addresses.ccipAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Xlayer is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.XLAYER;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.xlayerAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}

contract Megaeth is BaseSetCCRAdapters {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.MEGAETH;
  }

  function getChainIds() public pure virtual override returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    return chainIds;
  }

  function getReceiverBridgeAdaptersToAllow(
    Addresses memory addresses
  ) public pure override returns (address[] memory) {
    address[] memory receiverBridgeAdaptersToAllow = new address[](1);
    receiverBridgeAdaptersToAllow[0] = addresses.megaethAdapter;

    return receiverBridgeAdaptersToAllow;
  }
}
