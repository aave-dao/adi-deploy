// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/console.sol';
import {ADITestBase} from '../../adi/ADITestBase.sol';
import {Addresses, Ethereum as PayloadEthereumScript} from '../../../scripts/payloads/adapters/ethereum/Network_Deployments.s.sol';
import {SimpleAddForwarderAdapter, AddForwarderAdapterArgs} from '../../../src/templates/SimpleAddForwarderAdapter.sol';

abstract contract BaseAddBobPathPayloadTest is ADITestBase {
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
      string.concat('add_bob_path_to_adi', NETWORK),
      _crossChainController,
      address(_payload),
      false,
      vm
    );
  }

  function test_samePayloadAddress(
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

contract EthereumAddBobPathPayloadTest is
  PayloadEthereumScript,
  BaseAddBobPathPayloadTest('ethereum', 22766645)
{
  function _getDeployedPayload() internal pure override returns (address) {
    return 0xb46874c48b8F1d7303bC40F1c9E4bB4f159FCCf9;
  }

  function _getCurrentNetworkAddresses() internal view override returns (Addresses memory) {
    return _getAddresses(TRANSACTION_NETWORK());
  }

  function _getPayload() internal override returns (address) {
    Addresses memory currentAddresses = _getCurrentNetworkAddresses();
    Addresses memory destinationAddresses = _getAddresses(DESTINATION_CHAIN_ID());

    AddForwarderAdapterArgs memory args = AddForwarderAdapterArgs({
      crossChainController: currentAddresses.crossChainController,
      currentChainBridgeAdapter: currentAddresses.bobAdapter, // ethereum -> bob bridge adapter
      destinationChainBridgeAdapter: destinationAddresses.bobAdapter, // bob bridge adapter
      destinationChainId: DESTINATION_CHAIN_ID()
    });
    return _deployPayload(args);
  }
}
