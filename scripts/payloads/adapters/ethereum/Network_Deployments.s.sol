// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../../../BaseDeployerScript.sol';
import {Ethereum_Activate_Celo_Bridge_Adapter_Payload} from './Ethereum_Activate_Celo_Bridge_Adapter_Payload.s.sol';
import {Ethereum_Activate_Lina_Bridge_Adapter_Payload} from './Ethereum_Activate_Lina_Bridge_Adapter_Payload.s.sol';
import {Ethereum_Activate_Sonic_Bridge_Adapter_Payload} from './Ethereum_Activate_Sonic_Bridge_Adapter_Payload.s.sol';
import {Ethereum_Activate_Mantle_Bridge_Adapter_Payload} from './Ethereum_Activate_Mantle_Bridge_Adapter_Payload.s.sol';
import {Ethereum_Activate_Ink_Bridge_Adapter_Payload} from './Ethereum_Activate_Ink_Bridge_Adapter_Payload.s.sol';
import {Ethereum_Activate_Soneium_Bridge_Adapter_Payload} from './Ethereum_Activate_Soneium_Bridge_Adapter_Payload.s.sol';
import {Ethereum_Activate_Plasma_Bridge_Adapter_Payload} from './Ethereum_Activate_Plasma_Bridge_Adapter_Payload.s.sol';
import {Ethereum_Celo_Path_Payload} from '../../../../src/adapter_payloads/Ethereum_Celo_Path_Payload.sol';
import {Ethereum_Sonic_Path_Payload} from '../../../../src/adapter_payloads/Ethereum_Sonic_Path_Payload.sol';
import {SimpleAddForwarderAdapter} from '../../../../src/templates/SimpleAddForwarderAdapter.sol';
import {Ethereum_Plasma_Path_Payload} from '../../../../src/adapter_payloads/Ethereum_Plasma_Path_Payload.sol';
import {Ethereum_Activate_Bob_Bridge_Adapter_Payload} from './Ethereum_Activate_Bob_Bridge_Adapter_Payload.s.sol';

contract Ethereum is Ethereum_Activate_Bob_Bridge_Adapter_Payload {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function _getPayloadByteCode() internal pure override returns (bytes memory) {
    return type(SimpleAddForwarderAdapter).creationCode;
  }

  function DESTINATION_CHAIN_ID() internal pure override returns (uint256) {
    return ChainIds.BOB;
  }
}

contract Ethereum_Plasma is Ethereum_Activate_Plasma_Bridge_Adapter_Payload {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function _getPayloadByteCode() internal pure override returns (bytes memory) {
    return type(Ethereum_Plasma_Path_Payload).creationCode;
  }

  function DESTINATION_CHAIN_ID() internal pure override returns (uint256) {
    return ChainIds.PLASMA;
  }
}

contract Ethereum_Soneium is Ethereum_Activate_Soneium_Bridge_Adapter_Payload {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function _getPayloadByteCode() internal pure override returns (bytes memory) {
    return type(SimpleAddForwarderAdapter).creationCode;
  }

  function DESTINATION_CHAIN_ID() internal pure override returns (uint256) {
    return ChainIds.SONEIUM;
  }
}

contract Ethereum_Ink is Ethereum_Activate_Ink_Bridge_Adapter_Payload {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function _getPayloadByteCode() internal pure override returns (bytes memory) {
    return type(SimpleAddForwarderAdapter).creationCode;
  }

  function DESTINATION_CHAIN_ID() internal pure override returns (uint256) {
    return ChainIds.INK;
  }
}

contract Ethereum_Mantle is Ethereum_Activate_Mantle_Bridge_Adapter_Payload {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function _getPayloadByteCode() internal pure override returns (bytes memory) {
    return type(SimpleAddForwarderAdapter).creationCode;
  }

  function DESTINATION_CHAIN_ID() internal pure override returns (uint256) {
    return ChainIds.MANTLE;
  }
}

contract Ethereum_Sonic is Ethereum_Activate_Sonic_Bridge_Adapter_Payload {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function _getPayloadByteCode() internal pure override returns (bytes memory) {
    return type(Ethereum_Sonic_Path_Payload).creationCode;
  }

  function DESTINATION_CHAIN_ID() internal pure override returns (uint256) {
    return ChainIds.SONIC;
  }
}

contract Ethereum_Celo is Ethereum_Activate_Celo_Bridge_Adapter_Payload {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function _getPayloadByteCode() internal pure override returns (bytes memory) {
    return type(Ethereum_Celo_Path_Payload).creationCode;
  }

  function DESTINATION_CHAIN_ID() internal pure override returns (uint256) {
    return ChainIds.CELO;
  }
}

contract Ethereum_Linea is Ethereum_Activate_Lina_Bridge_Adapter_Payload {
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
