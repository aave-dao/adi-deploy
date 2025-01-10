// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../../../BaseDeployerScript.sol';
import '../../../../src/adapter_payloads/Ethereum_Celo_Path_Payload.sol';

abstract contract Ethereum_Activate_Celo_Bridge_Adapter_Payload is BaseDeployerScript {
  function _getPayloadByteCode() internal virtual returns (bytes memory);

  function PAYLOAD_SALT() internal pure virtual returns (string memory) {
    return 'Add Celo path to a.DI';
  }

  function DESTINATION_CHAIN_ID() internal pure virtual returns (uint256);

  function _deployPayload(AddForwarderAdapterArgs memory args) internal returns (address) {
    bytes memory payloadCode = abi.encodePacked(_getPayloadByteCode(), abi.encode(args));

    return _deployByteCode(payloadCode, PAYLOAD_SALT());
  }

  function _execute(Addresses memory addresses) internal virtual override {
    Addresses memory destinationAddresses = _getAddresses(DESTINATION_CHAIN_ID());

    _deployPayload(
      AddForwarderAdapterArgs({
        crossChainController: addresses.crossChainController,
        currentChainHLBridgeAdapter: addresses.hlAdapter,
        destinationChainHLBridgeAdapter: destinationAddresses.hlAdapter,
        currentChainCCIPBridgeAdapter: addresses.ccipAdapter,
        destinationChainCCIPBridgeAdapter: destinationAddresses.ccipAdapter,
        currentChainLZBridgeAdapter: addresses.lzAdapter,
        destinationChainLZBridgeAdapter: destinationAddresses.lzAdapter,
        destinationChainId: DESTINATION_CHAIN_ID()
      })
    );
  }
}
