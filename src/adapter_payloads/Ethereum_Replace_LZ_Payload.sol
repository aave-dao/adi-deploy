// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ChainIds} from 'solidity-utils/contracts/utils/ChainHelpers.sol';
import '../templates/BaseAdaptersUpdate.sol';

struct EthereumReplaceLZArgs {
  address crossChainController;
  address currentChainLZBridgeAdapter;
  address currentChainMonadLZBridgeAdapter;
  address currentChainWormholeExecutorBridgeAdapter;
  address currentChainGnosisCCIPBridgeAdapter;
  address polygonWormholeExecutorBridgeAdapter;
  address avalancheWormholeExecutorBridgeAdapter;
  address binanceWormholeExecutorBridgeAdapter;
  address monadWormholeExecutorBridgeAdapter;
  address gnosisCCIPBridgeAdapter;
}

/**
 * @title Ethereum_Replace_LZ_Payload
 * @dev replaces the LayerZero adapter with Wormhole Executor on the Polygon, Avalanche, BNB and Monad paths
 *      and with CCIP on the Gnosis path. Confirmations and optimal bandwidth are left unchanged.
 */
contract Ethereum_Replace_LZ_Payload is BaseAdaptersUpdate {
  address public immutable CURRENT_CHAIN_LZ_BRIDGE_ADAPTER;
  address public immutable CURRENT_CHAIN_MONAD_LZ_BRIDGE_ADAPTER;
  address public immutable CURRENT_CHAIN_WORMHOLE_EXECUTOR_BRIDGE_ADAPTER;
  address public immutable CURRENT_CHAIN_GNOSIS_CCIP_BRIDGE_ADAPTER;
  address public immutable POLYGON_WORMHOLE_EXECUTOR_BRIDGE_ADAPTER;
  address public immutable AVALANCHE_WORMHOLE_EXECUTOR_BRIDGE_ADAPTER;
  address public immutable BINANCE_WORMHOLE_EXECUTOR_BRIDGE_ADAPTER;
  address public immutable MONAD_WORMHOLE_EXECUTOR_BRIDGE_ADAPTER;
  address public immutable GNOSIS_CCIP_BRIDGE_ADAPTER;

  constructor(EthereumReplaceLZArgs memory args) BaseAdaptersUpdate(args.crossChainController) {
    CURRENT_CHAIN_LZ_BRIDGE_ADAPTER = args.currentChainLZBridgeAdapter;
    CURRENT_CHAIN_MONAD_LZ_BRIDGE_ADAPTER = args.currentChainMonadLZBridgeAdapter;
    CURRENT_CHAIN_WORMHOLE_EXECUTOR_BRIDGE_ADAPTER = args.currentChainWormholeExecutorBridgeAdapter;
    CURRENT_CHAIN_GNOSIS_CCIP_BRIDGE_ADAPTER = args.currentChainGnosisCCIPBridgeAdapter;
    POLYGON_WORMHOLE_EXECUTOR_BRIDGE_ADAPTER = args.polygonWormholeExecutorBridgeAdapter;
    AVALANCHE_WORMHOLE_EXECUTOR_BRIDGE_ADAPTER = args.avalancheWormholeExecutorBridgeAdapter;
    BINANCE_WORMHOLE_EXECUTOR_BRIDGE_ADAPTER = args.binanceWormholeExecutorBridgeAdapter;
    MONAD_WORMHOLE_EXECUTOR_BRIDGE_ADAPTER = args.monadWormholeExecutorBridgeAdapter;
    GNOSIS_CCIP_BRIDGE_ADAPTER = args.gnosisCCIPBridgeAdapter;
  }

  function getReceiverBridgeAdaptersToRemove()
    public
    view
    override
    returns (ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory)
  {
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory receivers = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](1);
    receivers[0] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
      bridgeAdapter: CURRENT_CHAIN_LZ_BRIDGE_ADAPTER,
      chainIds: _returnPathChainIds()
    });
    return receivers;
  }

  function getReceiverBridgeAdaptersToAllow()
    public
    view
    override
    returns (ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory)
  {
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory receivers = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](1);
    receivers[0] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
      bridgeAdapter: CURRENT_CHAIN_WORMHOLE_EXECUTOR_BRIDGE_ADAPTER,
      chainIds: _returnPathChainIds()
    });
    return receivers;
  }

  function getForwarderBridgeAdaptersToRemove()
    public
    view
    override
    returns (ICrossChainForwarder.BridgeAdapterToDisable[] memory)
  {
    uint256[] memory lzChainIds = new uint256[](4);
    lzChainIds[0] = ChainIds.POLYGON;
    lzChainIds[1] = ChainIds.AVALANCHE;
    lzChainIds[2] = ChainIds.BNB;
    lzChainIds[3] = ChainIds.GNOSIS;

    uint256[] memory monadChainIds = new uint256[](1);
    monadChainIds[0] = ChainIds.MONAD;

    ICrossChainForwarder.BridgeAdapterToDisable[]
      memory forwarders = new ICrossChainForwarder.BridgeAdapterToDisable[](2);
    forwarders[0] = ICrossChainForwarder.BridgeAdapterToDisable({
      bridgeAdapter: CURRENT_CHAIN_LZ_BRIDGE_ADAPTER,
      chainIds: lzChainIds
    });
    forwarders[1] = ICrossChainForwarder.BridgeAdapterToDisable({
      bridgeAdapter: CURRENT_CHAIN_MONAD_LZ_BRIDGE_ADAPTER,
      chainIds: monadChainIds
    });
    return forwarders;
  }

  function getForwarderBridgeAdaptersToEnable()
    public
    view
    override
    returns (ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[] memory)
  {
    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[]
      memory forwarders = new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](5);
    forwarders[0] = _wormholeForwarder(POLYGON_WORMHOLE_EXECUTOR_BRIDGE_ADAPTER, ChainIds.POLYGON);
    forwarders[1] = _wormholeForwarder(
      AVALANCHE_WORMHOLE_EXECUTOR_BRIDGE_ADAPTER,
      ChainIds.AVALANCHE
    );
    forwarders[2] = _wormholeForwarder(BINANCE_WORMHOLE_EXECUTOR_BRIDGE_ADAPTER, ChainIds.BNB);
    forwarders[3] = _wormholeForwarder(MONAD_WORMHOLE_EXECUTOR_BRIDGE_ADAPTER, ChainIds.MONAD);
    forwarders[4] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
      currentChainBridgeAdapter: CURRENT_CHAIN_GNOSIS_CCIP_BRIDGE_ADAPTER,
      destinationBridgeAdapter: GNOSIS_CCIP_BRIDGE_ADAPTER,
      destinationChainId: ChainIds.GNOSIS
    });
    return forwarders;
  }

  function _wormholeForwarder(
    address destinationBridgeAdapter,
    uint256 destinationChainId
  ) internal view returns (ICrossChainForwarder.ForwarderBridgeAdapterConfigInput memory) {
    return
      ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
        currentChainBridgeAdapter: CURRENT_CHAIN_WORMHOLE_EXECUTOR_BRIDGE_ADAPTER,
        destinationBridgeAdapter: destinationBridgeAdapter,
        destinationChainId: destinationChainId
      });
  }

  /// @dev chains that send messages back to Ethereum
  function _returnPathChainIds() internal pure returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](2);
    chainIds[0] = ChainIds.POLYGON;
    chainIds[1] = ChainIds.AVALANCHE;
    return chainIds;
  }
}
