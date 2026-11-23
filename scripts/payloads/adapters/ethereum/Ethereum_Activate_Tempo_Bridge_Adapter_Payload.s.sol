// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../../../BaseDeployerScript.sol';
import '../../../../src/adapter_payloads/Ethereum_Tempo_Path_Payload.sol';

abstract contract Ethereum_Activate_Tempo_Bridge_Adapter_Payload is BaseDeployerScript {
  function _getPayloadByteCode() internal virtual returns (bytes memory);

  function PAYLOAD_SALT() internal pure virtual returns (string memory) {
    return 'Add path to a.DI for Tempo';
  }

  function DESTINATION_CHAIN_ID() internal pure virtual returns (uint256);

  function _deployPayload(AddTempoForwarderAdapterArgs memory args) internal returns (address) {
    bytes memory payloadCode = abi.encodePacked(_getPayloadByteCode(), abi.encode(args));

    return _deployByteCode(payloadCode, PAYLOAD_SALT());
  }

  /// @dev the Ethereum adapters are the ones dedicated to the Tempo path
  function _getPayloadArgs(
    Addresses memory currentAddresses,
    Addresses memory destinationAddresses
  ) internal pure returns (AddTempoForwarderAdapterArgs memory) {
    return
      AddTempoForwarderAdapterArgs({
        crossChainController: currentAddresses.crossChainController,
        currentChainCCIPBridgeAdapter: currentAddresses.ccipAdapterTempo,
        destinationChainCCIPBridgeAdapter: destinationAddresses.ccipAdapter,
        currentChainHLBridgeAdapter: currentAddresses.hlAdapterTempo,
        destinationChainHLBridgeAdapter: destinationAddresses.hlAdapter,
        currentChainWormholeExecutorBridgeAdapter: currentAddresses.wormholeExecutorAdapterTempo,
        destinationChainWormholeExecutorBridgeAdapter: destinationAddresses.wormholeExecutorAdapter,
        destinationChainId: destinationAddresses.chainId
      });
  }

  function _execute(Addresses memory addresses) internal virtual override {
    Addresses memory destinationAddresses = _getAddresses(DESTINATION_CHAIN_ID());
    require(destinationAddresses.chainId == DESTINATION_CHAIN_ID(), 'wrong destination');

    _deployPayload(_getPayloadArgs(addresses, destinationAddresses));
  }
}
