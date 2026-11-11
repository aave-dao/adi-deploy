// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../../../BaseDeployerScript.sol';
import {CCIPAdapter} from 'adi/adapters/ccip/CCIPAdapter.sol';
import {Ethereum_Replace_LZ_Payload, EthereumReplaceLZArgs} from '../../../../src/adapter_payloads/Ethereum_Replace_LZ_Payload.sol';
import {Remote_Replace_LZ_Payload, RemoteReplaceLZArgs} from '../../../../src/adapter_payloads/Remote_Replace_LZ_Payload.sol';

abstract contract Replace_LZ_Payload is BaseDeployerScript {
  uint64 internal constant GNOSIS_CCIP_CHAIN_SELECTOR = 465200170687744372;

  function PAYLOAD_SALT() internal pure virtual returns (string memory) {
    return 'Replace LayerZero adapter in a.DI';
  }

  function _wormholeExecutorAdapter(uint256 chainId) internal view virtual returns (address) {
    return _getAddresses(chainId).wormholeExecutorAdapter;
  }

  /// @dev on Ethereum this is the CCIP adapter dedicated to the Gnosis path
  function _gnosisPathCCIPAdapter(uint256 chainId) internal view virtual returns (address) {
    return _getAddresses(chainId).ccipAdapter;
  }

  function _deployPayload(bytes memory payloadCode) internal returns (address) {
    return _deployByteCode(payloadCode, PAYLOAD_SALT());
  }

  function _requireDeployed(address adapter) internal view {
    require(adapter.code.length != 0, 'new adapter not deployed on current network');
  }
}

contract Ethereum is Replace_LZ_Payload {
  /// @dev shared by the Polygon, Avalanche, BNB, Gnosis and Celo paths; Celo keeps it
  address internal constant LZ_BRIDGE_ADAPTER = 0x8410d9BD353b420ebA8C48ff1B0518426C280FCC;
  address internal constant MONAD_LZ_BRIDGE_ADAPTER = 0xf9482751C9937fF940b93B5921B8984645dD0a53;

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function _getPayloadArgs(
    Addresses memory addresses
  ) internal view returns (EthereumReplaceLZArgs memory) {
    return
      EthereumReplaceLZArgs({
        crossChainController: addresses.crossChainController,
        currentChainLZBridgeAdapter: LZ_BRIDGE_ADAPTER,
        currentChainMonadLZBridgeAdapter: MONAD_LZ_BRIDGE_ADAPTER,
        currentChainWormholeExecutorBridgeAdapter: _wormholeExecutorAdapter(ChainIds.ETHEREUM),
        currentChainGnosisCCIPBridgeAdapter: _gnosisPathCCIPAdapter(ChainIds.ETHEREUM),
        polygonWormholeExecutorBridgeAdapter: _wormholeExecutorAdapter(ChainIds.POLYGON),
        avalancheWormholeExecutorBridgeAdapter: _wormholeExecutorAdapter(ChainIds.AVALANCHE),
        binanceWormholeExecutorBridgeAdapter: _wormholeExecutorAdapter(ChainIds.BNB),
        monadWormholeExecutorBridgeAdapter: _wormholeExecutorAdapter(ChainIds.MONAD),
        gnosisCCIPBridgeAdapter: _gnosisPathCCIPAdapter(ChainIds.GNOSIS)
      });
  }

  function _deployPayload(EthereumReplaceLZArgs memory args) internal returns (address) {
    _requireDeployed(args.currentChainWormholeExecutorBridgeAdapter);
    _requireDeployed(args.currentChainGnosisCCIPBridgeAdapter);
    // ethereum.json `ccipAdapter` must hold the Gnosis-path adapter, not an older one without the mapping
    require(
      // CCIPAdapter declares the mapping pure, so this stays a local call and is not broadcast
      CCIPAdapter(args.currentChainGnosisCCIPBridgeAdapter).infraToNativeChainId(
        ChainIds.GNOSIS
      ) == GNOSIS_CCIP_CHAIN_SELECTOR,
      'ccipAdapter is not the Gnosis path adapter'
    );
    require(
      args.polygonWormholeExecutorBridgeAdapter != address(0) &&
        args.avalancheWormholeExecutorBridgeAdapter != address(0) &&
        args.binanceWormholeExecutorBridgeAdapter != address(0) &&
        args.monadWormholeExecutorBridgeAdapter != address(0) &&
        args.gnosisCCIPBridgeAdapter != address(0),
      'remote adapters not deployed'
    );
    return
      _deployPayload(
        abi.encodePacked(type(Ethereum_Replace_LZ_Payload).creationCode, abi.encode(args))
      );
  }

  function _execute(Addresses memory addresses) internal override {
    _deployPayload(_getPayloadArgs(addresses));
  }
}

abstract contract Remote_Replace_LZ is Replace_LZ_Payload {
  function _newAdapter() internal view virtual returns (address);

  /// @dev Ethereum counterpart for chains that also forward to Ethereum
  function _destinationNewAdapter() internal view virtual returns (address) {
    return address(0);
  }

  function _getPayloadArgs(
    Addresses memory addresses
  ) internal view returns (RemoteReplaceLZArgs memory) {
    return
      RemoteReplaceLZArgs({
        crossChainController: addresses.crossChainController,
        currentChainLZBridgeAdapter: addresses.lzAdapter,
        currentChainNewBridgeAdapter: _newAdapter(),
        destinationChainNewBridgeAdapter: _destinationNewAdapter()
      });
  }

  function _deployPayload(RemoteReplaceLZArgs memory args) internal returns (address) {
    require(args.currentChainLZBridgeAdapter != address(0), 'LZ adapter missing from json');
    _requireDeployed(args.currentChainNewBridgeAdapter);
    return
      _deployPayload(
        abi.encodePacked(type(Remote_Replace_LZ_Payload).creationCode, abi.encode(args))
      );
  }

  function _execute(Addresses memory addresses) internal override {
    _deployPayload(_getPayloadArgs(addresses));
  }
}

abstract contract Remote_Replace_LZ_With_Wormhole is Remote_Replace_LZ {
  function _newAdapter() internal view override returns (address) {
    return _wormholeExecutorAdapter(TRANSACTION_NETWORK());
  }
}

contract Polygon is Remote_Replace_LZ_With_Wormhole {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.POLYGON;
  }

  function _destinationNewAdapter() internal view override returns (address) {
    return _wormholeExecutorAdapter(ChainIds.ETHEREUM);
  }
}

contract Avalanche is Remote_Replace_LZ_With_Wormhole {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.AVALANCHE;
  }

  function _destinationNewAdapter() internal view override returns (address) {
    return _wormholeExecutorAdapter(ChainIds.ETHEREUM);
  }
}

contract Binance is Remote_Replace_LZ_With_Wormhole {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.BNB;
  }
}

contract Monad is Remote_Replace_LZ_With_Wormhole {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.MONAD;
  }
}

contract Gnosis is Remote_Replace_LZ {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.GNOSIS;
  }

  function _newAdapter() internal view override returns (address) {
    return _gnosisPathCCIPAdapter(TRANSACTION_NETWORK());
  }
}
