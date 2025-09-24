// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseDeployerScript.sol';
import {ICrossChainForwarder} from 'adi/interfaces/ICrossChainForwarder.sol';
import {ICrossChainReceiver} from 'adi/interfaces/ICrossChainReceiver.sol';

abstract contract BaseRemoveBridgeAdapters is BaseDeployerScript {
  function getBridgeAdaptersToDisable()
    internal
    view
    virtual
    returns (ICrossChainForwarder.BridgeAdapterToDisable[] memory);

  function getReceiverBridgeAdaptersToDisallow()
    internal
    view
    virtual
    returns (ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory);

  function _execute(Addresses memory addresses) internal override {
    ICrossChainForwarder(addresses.crossChainController).disableBridgeAdapters(
      getBridgeAdaptersToDisable()
    );
    ICrossChainReceiver(addresses.crossChainController).disallowReceiverBridgeAdapters(
      getReceiverBridgeAdaptersToDisallow()
    );
  }
}

contract Celo is BaseRemoveBridgeAdapters {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.CELO;
  }

  function getBridgeAdaptersToDisable()
    internal
    pure
    override
    returns (ICrossChainForwarder.BridgeAdapterToDisable[] memory)
  {
    ICrossChainForwarder.BridgeAdapterToDisable[]
      memory bridgeAdapters = new ICrossChainForwarder.BridgeAdapterToDisable[](0);
    return bridgeAdapters;
  }

  function getReceiverBridgeAdaptersToDisallow()
    internal
    pure
    override
    returns (ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory)
  {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory bridgeAdapters = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](2);
    bridgeAdapters[0] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
      bridgeAdapter: 0xa5cc218513305221201f196760E9e64e9D49d98A,
      chainIds: chainIds
    });
    bridgeAdapters[1] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
      bridgeAdapter: 0xAE93BEa44dcbE52B625169588574d31e36fb3A67,
      chainIds: chainIds
    });
    return bridgeAdapters;
  }
}

contract Linea is BaseRemoveBridgeAdapters {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.LINEA;
  }

  function getBridgeAdaptersToDisable()
    internal
    pure
    override
    returns (ICrossChainForwarder.BridgeAdapterToDisable[] memory)
  {
    ICrossChainForwarder.BridgeAdapterToDisable[]
      memory bridgeAdapters = new ICrossChainForwarder.BridgeAdapterToDisable[](0);
    return bridgeAdapters;
  }

  function getReceiverBridgeAdaptersToDisallow()
    internal
    pure
    override
    returns (ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory)
  {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory bridgeAdapters = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](1);
    bridgeAdapters[0] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
      bridgeAdapter: 0xcE7741c1d99f0A8048eA8f19CB25C506Fb31d6cb,
      chainIds: chainIds
    });

    return bridgeAdapters;
  }
}

contract Ethereum is BaseRemoveBridgeAdapters {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function getBridgeAdaptersToDisable()
    internal
    pure
    override
    returns (ICrossChainForwarder.BridgeAdapterToDisable[] memory)
  {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.LINEA;

    ICrossChainForwarder.BridgeAdapterToDisable[]
      memory bridgeAdapters = new ICrossChainForwarder.BridgeAdapterToDisable[](1);
    bridgeAdapters[0] = ICrossChainForwarder.BridgeAdapterToDisable({
      bridgeAdapter: 0xC8135D3a64E00ACd72905928a307FC4c469A95F6,
      chainIds: chainIds
    });
    return bridgeAdapters;
  }

  function getReceiverBridgeAdaptersToDisallow()
    internal
    pure
    override
    returns (ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory)
  {
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory bridgeAdapters = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0);

    return bridgeAdapters;
  }
}
