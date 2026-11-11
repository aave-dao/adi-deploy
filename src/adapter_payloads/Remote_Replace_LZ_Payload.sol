// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ChainIds} from 'solidity-utils/contracts/utils/ChainHelpers.sol';
import '../templates/BaseAdaptersUpdate.sol';

struct RemoteReplaceLZArgs {
  address crossChainController;
  address currentChainLZBridgeAdapter;
  address currentChainNewBridgeAdapter;
  /// @dev Ethereum counterpart of the new adapter; address(0) on chains that do not forward to Ethereum
  address destinationChainNewBridgeAdapter;
}

/**
 * @title Remote_Replace_LZ_Payload
 * @dev replaces the LayerZero adapter on the Ethereum path of a remote chain. Confirmations and optimal
 *      bandwidth are left unchanged.
 */
contract Remote_Replace_LZ_Payload is BaseAdaptersUpdate {
  address public immutable CURRENT_CHAIN_LZ_BRIDGE_ADAPTER;
  address public immutable CURRENT_CHAIN_NEW_BRIDGE_ADAPTER;
  address public immutable DESTINATION_CHAIN_NEW_BRIDGE_ADAPTER;

  constructor(RemoteReplaceLZArgs memory args) BaseAdaptersUpdate(args.crossChainController) {
    CURRENT_CHAIN_LZ_BRIDGE_ADAPTER = args.currentChainLZBridgeAdapter;
    CURRENT_CHAIN_NEW_BRIDGE_ADAPTER = args.currentChainNewBridgeAdapter;
    DESTINATION_CHAIN_NEW_BRIDGE_ADAPTER = args.destinationChainNewBridgeAdapter;
  }

  function getReceiverBridgeAdaptersToRemove()
    public
    view
    override
    returns (ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory)
  {
    return _ethereumReceiver(CURRENT_CHAIN_LZ_BRIDGE_ADAPTER);
  }

  function getReceiverBridgeAdaptersToAllow()
    public
    view
    override
    returns (ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory)
  {
    return _ethereumReceiver(CURRENT_CHAIN_NEW_BRIDGE_ADAPTER);
  }

  function getForwarderBridgeAdaptersToRemove()
    public
    view
    override
    returns (ICrossChainForwarder.BridgeAdapterToDisable[] memory)
  {
    if (DESTINATION_CHAIN_NEW_BRIDGE_ADAPTER == address(0)) {
      return new ICrossChainForwarder.BridgeAdapterToDisable[](0);
    }
    ICrossChainForwarder.BridgeAdapterToDisable[]
      memory forwarders = new ICrossChainForwarder.BridgeAdapterToDisable[](1);
    forwarders[0] = ICrossChainForwarder.BridgeAdapterToDisable({
      bridgeAdapter: CURRENT_CHAIN_LZ_BRIDGE_ADAPTER,
      chainIds: _ethereumChainId()
    });
    return forwarders;
  }

  function getForwarderBridgeAdaptersToEnable()
    public
    view
    override
    returns (ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[] memory)
  {
    if (DESTINATION_CHAIN_NEW_BRIDGE_ADAPTER == address(0)) {
      return new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](0);
    }
    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[]
      memory forwarders = new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](1);
    forwarders[0] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
      currentChainBridgeAdapter: CURRENT_CHAIN_NEW_BRIDGE_ADAPTER,
      destinationBridgeAdapter: DESTINATION_CHAIN_NEW_BRIDGE_ADAPTER,
      destinationChainId: ChainIds.ETHEREUM
    });
    return forwarders;
  }

  function _ethereumReceiver(
    address bridgeAdapter
  ) internal pure returns (ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory) {
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory receivers = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](1);
    receivers[0] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
      bridgeAdapter: bridgeAdapter,
      chainIds: _ethereumChainId()
    });
    return receivers;
  }

  function _ethereumChainId() internal pure returns (uint256[] memory) {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;
    return chainIds;
  }
}
