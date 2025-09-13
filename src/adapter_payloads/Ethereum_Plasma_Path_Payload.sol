// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../templates/BaseAdaptersUpdate.sol';

struct AddForwarderAdapterArgs {
  address crossChainController;
  address currentChainHLBridgeAdapter;
  address destinationChainHLBridgeAdapter;
  address currentChainLZBridgeAdapter;
  address destinationChainLZBridgeAdapter;
  address currentChainCCIPBridgeAdapter;
  address destinationChainCCIPBridgeAdapter;
  uint256 destinationChainId;
}

/**
 * @title Ethereum_Plasma_Path_Payload
 * @author BGD Labs @bgdlabs
 * @dev this payload adds a new bridging path to adi with multiple forwarder adapters
 */
contract Ethereum_Plasma_Path_Payload is BaseAdaptersUpdate {
  address public immutable CURRENT_CHAIN_HL_BRIDGE_ADAPTER;
  address public immutable DESTINATION_CHAIN_HL_BRIDGE_ADAPTER;
  address public immutable CURRENT_CHAIN_CCIP_BRIDGE_ADAPTER;
  address public immutable DESTINATION_CHAIN_CCIP_BRIDGE_ADAPTER;
  address public immutable CURRENT_CHAIN_LZ_BRIDGE_ADAPTER;
  address public immutable DESTINATION_CHAIN_LZ_BRIDGE_ADAPTER;
  uint256 public immutable DESTINATION_CHAIN_ID;

  constructor(
    AddForwarderAdapterArgs memory forwarderArgs
  ) BaseAdaptersUpdate(forwarderArgs.crossChainController) {
    CURRENT_CHAIN_HL_BRIDGE_ADAPTER = forwarderArgs.currentChainHLBridgeAdapter;
    DESTINATION_CHAIN_HL_BRIDGE_ADAPTER = forwarderArgs.destinationChainHLBridgeAdapter;
    CURRENT_CHAIN_CCIP_BRIDGE_ADAPTER = forwarderArgs.currentChainCCIPBridgeAdapter;
    DESTINATION_CHAIN_CCIP_BRIDGE_ADAPTER = forwarderArgs.destinationChainCCIPBridgeAdapter;
    CURRENT_CHAIN_LZ_BRIDGE_ADAPTER = forwarderArgs.currentChainLZBridgeAdapter;
    DESTINATION_CHAIN_LZ_BRIDGE_ADAPTER = forwarderArgs.destinationChainLZBridgeAdapter;
    DESTINATION_CHAIN_ID = forwarderArgs.destinationChainId;
  }

  function getForwarderBridgeAdaptersToEnable()
    public
    view
    override
    returns (ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[] memory)
  {
    ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[]
      memory newForwarders = new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](3);

    newForwarders[0] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
        currentChainBridgeAdapter: CURRENT_CHAIN_HL_BRIDGE_ADAPTER,
        destinationBridgeAdapter: DESTINATION_CHAIN_HL_BRIDGE_ADAPTER,
        destinationChainId: DESTINATION_CHAIN_ID
        });

    newForwarders[1] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
        currentChainBridgeAdapter: CURRENT_CHAIN_CCIP_BRIDGE_ADAPTER,
        destinationBridgeAdapter: DESTINATION_CHAIN_CCIP_BRIDGE_ADAPTER,
        destinationChainId: DESTINATION_CHAIN_ID
        });

    newForwarders[2] = ICrossChainForwarder.ForwarderBridgeAdapterConfigInput({
        currentChainBridgeAdapter: CURRENT_CHAIN_LZ_BRIDGE_ADAPTER,
        destinationBridgeAdapter: DESTINATION_CHAIN_LZ_BRIDGE_ADAPTER,
        destinationChainId: DESTINATION_CHAIN_ID
        });

    return newForwarders;
  }

  function execute() public override {
    executeReceiversUpdate(CROSS_CHAIN_CONTROLLER);

    executeForwardersUpdate(CROSS_CHAIN_CONTROLLER);

    _updateOptimalBandwidth();
  }

  function _updateOptimalBandwidth() public {
    ICrossChainForwarder.OptimalBandwidthByChain[] memory optimalBandwidthByChain = 
      new ICrossChainForwarder.OptimalBandwidthByChain[](1);
    optimalBandwidthByChain[0] = ICrossChainForwarder.OptimalBandwidthByChain({
      chainId: DESTINATION_CHAIN_ID,
      optimalBandwidth: 2
    });
    ICrossChainForwarder(CROSS_CHAIN_CONTROLLER).updateOptimalBandwidthByChain(
      optimalBandwidthByChain
    );
  }
}
