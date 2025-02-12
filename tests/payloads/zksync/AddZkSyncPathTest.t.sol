// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/console.sol';
import {ADITestBase} from '../../adi/ADITestBase.sol';
import {Addresses, Ethereum as PayloadEthereumScript} from '../../../scripts/payloads/adapters/zksync/Network_Deployments.s.sol';
import '../../../src/templates/SimpleAddForwarderAdapter.sol';

abstract contract BaseAddZkSyncPathPayloadTest is ADITestBase {
  address internal _payload;
  address internal _crossChainController;

  string internal NETWORK;
  uint256 internal immutable BLOCK_NUMBER;

  constructor(string memory network, uint256 blockNumber) {
    NETWORK = network;
    BLOCK_NUMBER = blockNumber;
  }

  function _getDeployedPayload() internal virtual returns (address);

  function _getPayload() internal virtual returns (address);

  function _getCurrentNetworkAddresses() internal virtual returns (Addresses memory);

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl(NETWORK), BLOCK_NUMBER);

    Addresses memory addresses = _getCurrentNetworkAddresses();
    _crossChainController = addresses.crossChainController;

    _payload = _getPayload();
  }

  function test_defaultTest() public {
    defaultTest(
      string.concat('add_zksync_path_to_adi', NETWORK),
      _crossChainController,
      address(_payload),
      false,
      vm
    );
  }

  function xtest_samePayloadAddress(
    address currentChainAdapter,
    address destinationChainAdapter,
    address crossChainController,
    uint256 destinationChainId
  ) public {
    SimpleAddForwarderAdapter deployedPayload = SimpleAddForwarderAdapter(_getDeployedPayload());
    SimpleAddForwarderAdapter predictedPayload = SimpleAddForwarderAdapter(_getPayload());

    assertEq(predictedPayload.DESTINATION_CHAIN_ID(), deployedPayload.DESTINATION_CHAIN_ID());
    assertEq(predictedPayload.CROSS_CHAIN_CONTROLLER(), deployedPayload.CROSS_CHAIN_CONTROLLER());
    assertEq(
      predictedPayload.CURRENT_CHAIN_BRIDGE_ADAPTER(),
      deployedPayload.CURRENT_CHAIN_BRIDGE_ADAPTER()
    );
    assertEq(
      predictedPayload.DESTINATION_CHAIN_BRIDGE_ADAPTER(),
      deployedPayload.DESTINATION_CHAIN_BRIDGE_ADAPTER()
    );
  }
}

contract EthereumAddZkSyncPathPayloadTest is
  PayloadEthereumScript,
  BaseAddZkSyncPathPayloadTest('ethereum', 20413186)
{
  function _getDeployedPayload() internal pure override returns (address) {
    return 0x65Cf9DE21c5F4377BF7E4d1421cEde57d9D5962A;
  }

  function _getCurrentNetworkAddresses() internal view override returns (Addresses memory) {
    return _getAddresses(TRANSACTION_NETWORK());
  }

  function _getPayload() internal override returns (address) {
    Addresses memory currentAddresses = _getCurrentNetworkAddresses();
    Addresses memory destinationAddresses = _getAddresses(DESTINATION_CHAIN_ID());

    AddForwarderAdapterArgs memory args = AddForwarderAdapterArgs({
      crossChainController: currentAddresses.crossChainController,
      currentChainBridgeAdapter: 0x6aD9d4147467f08b165e1b6364584C5d28898b84,
      destinationChainBridgeAdapter: 0x1BC5C10CAe378fDbd7D52ec4F9f34590a619c68E,
      destinationChainId: DESTINATION_CHAIN_ID()
    });
    return _deployPayload(args);
  }
}
