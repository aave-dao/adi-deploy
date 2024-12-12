// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/console.sol';
import {ADITestBase} from '../../adi/ADITestBase.sol';
import {Addresses, Ethereum as PayloadEthereumScript} from '../../../scripts/payloads/adapters/ethereum/Network_Deployments.s.sol';
import '../../../src/templates/SimpleAddForwarderAdapter.sol';

abstract contract BaseAddLineaPathPayloadTest is ADITestBase {
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
      string.concat('add_linea_path_to_adi', NETWORK),
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

contract EthereumAddLineaPathPayloadTest is
  PayloadEthereumScript,
  BaseAddLineaPathPayloadTest('ethereum', 21386314)
{
  function _getDeployedPayload() internal pure override returns (address) {
    return 0x3C2A076cD5ECbed55D8Fc0A341c14Fc808bA7fF7;
  }

  function _getCurrentNetworkAddresses() internal view override returns (Addresses memory) {
    return _getAddresses(TRANSACTION_NETWORK());
  }

  function _getPayload() internal override returns (address) {
    Addresses memory currentAddresses = _getCurrentNetworkAddresses();
    Addresses memory destinationAddresses = _getAddresses(DESTINATION_CHAIN_ID());

    AddForwarderAdapterArgs memory args = AddForwarderAdapterArgs({
      crossChainController: currentAddresses.crossChainController,
      currentChainBridgeAdapter: 0x8097555ffDa4176C93FEf92dF473b9763e467686, // ethereum -> linea bridge adapter
      destinationChainBridgeAdapter: 0xB3332d31ECFC3ef3BF6Cda79833D11d1A53f5cE6, // linea bridge adapter
      destinationChainId: DESTINATION_CHAIN_ID()
    });
    return _deployPayload(args);
  }
}
