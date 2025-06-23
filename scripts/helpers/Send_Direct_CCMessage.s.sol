// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseDeployerScript.sol';
import {ICrossChainForwarder} from 'adi/interfaces/ICrossChainForwarder.sol';

abstract contract BaseSendDirectMessage is BaseDeployerScript {
  function DESTINATION_NETWORK() internal view virtual returns (uint256);

  function getDestinationAddress() internal view virtual returns (address) {
    return _getAddresses(DESTINATION_NETWORK()).mockDestination;
  }

  function getGasLimit() internal view virtual returns (uint256) {
    return 550_000;
  }

  function getMessage() internal view virtual returns (bytes memory) {
    return abi.encode('some random message');
  }

  function _execute(Addresses memory addresses) internal override {
    uint256 destinationChainId = _getAddresses(DESTINATION_NETWORK()).chainId;

    ICrossChainForwarder(addresses.crossChainController).forwardMessage(
      destinationChainId,
      getDestinationAddress(),
      getGasLimit(),
      getMessage()
    );
  }
}

contract Ethereum is BaseSendDirectMessage {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function DESTINATION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.BOB;
  }
}

contract Avalanche is BaseSendDirectMessage {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.AVALANCHE;
  }

  function DESTINATION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}

contract Polygon is BaseSendDirectMessage {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.POLYGON;
  }

  function DESTINATION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}

contract Ethereum_testnet is BaseSendDirectMessage {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  function DESTINATION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.LINEA_SEPOLIA;
  }
}

contract Avalanche_testnet is BaseSendDirectMessage {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.AVALANCHE_FUJI;
  }

  function DESTINATION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}

contract Polygon_testnet is BaseSendDirectMessage {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.POLYGON_AMOY;
  }

  function DESTINATION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}
