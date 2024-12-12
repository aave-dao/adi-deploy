// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './Ethereum_Activate_Lina_Bridge_Adapter_Payload.s.sol';

contract Ethereum is Ethereum_Activate_Lina_Bridge_Adapter_Payload {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function _getPayloadByteCode() internal pure override returns (bytes memory) {
    return type(SimpleAddForwarderAdapter).creationCode;
  }

  function DESTINATION_CHAIN_ID() internal pure override returns (uint256) {
    return ChainIds.LINEA;
  }
}
