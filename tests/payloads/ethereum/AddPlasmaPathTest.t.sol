// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ADITestBase} from '../../adi/ADITestBase.sol';
import {Addresses, Ethereum as PayloadEthereumScript} from '../../../scripts/payloads/adapters/ethereum/Network_Deployments.s.sol';
import {Ethereum_Plasma_Path_Payload, AddForwarderAdapterArgs} from '../../../src/adapter_payloads/Ethereum_Plasma_Path_Payload.sol';

abstract contract BaseAddPlasmaPathPayloadTest is ADITestBase {
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
      string.concat('add_plasma_path_to_adi', NETWORK),
      _crossChainController,
      address(_payload),
      false,
      vm
    );
  }

  function test_samePayloadAddress() public {
    Ethereum_Plasma_Path_Payload deployedPayload = Ethereum_Plasma_Path_Payload(
      _getDeployedPayload()
    );
    Ethereum_Plasma_Path_Payload predictedPayload = Ethereum_Plasma_Path_Payload(_getPayload());

    assertEq(predictedPayload.DESTINATION_CHAIN_ID(), deployedPayload.DESTINATION_CHAIN_ID());
    assertEq(predictedPayload.CROSS_CHAIN_CONTROLLER(), deployedPayload.CROSS_CHAIN_CONTROLLER());
    assertEq(
      predictedPayload.CURRENT_CHAIN_HL_BRIDGE_ADAPTER(),
      deployedPayload.CURRENT_CHAIN_HL_BRIDGE_ADAPTER()
    );
    assertEq(
      predictedPayload.DESTINATION_CHAIN_HL_BRIDGE_ADAPTER(),
      deployedPayload.DESTINATION_CHAIN_HL_BRIDGE_ADAPTER()
    );
    assertEq(
      predictedPayload.CURRENT_CHAIN_CCIP_BRIDGE_ADAPTER(),
      deployedPayload.CURRENT_CHAIN_CCIP_BRIDGE_ADAPTER()
    );
    assertEq(
      predictedPayload.DESTINATION_CHAIN_CCIP_BRIDGE_ADAPTER(),
      deployedPayload.DESTINATION_CHAIN_CCIP_BRIDGE_ADAPTER()
    );
    assertEq(
      predictedPayload.CURRENT_CHAIN_LZ_BRIDGE_ADAPTER(),
      deployedPayload.CURRENT_CHAIN_LZ_BRIDGE_ADAPTER()
    );
    assertEq(
      predictedPayload.DESTINATION_CHAIN_LZ_BRIDGE_ADAPTER(),
      deployedPayload.DESTINATION_CHAIN_LZ_BRIDGE_ADAPTER()
    );
  }
}

// TODO: add block number
contract EthereumAddPlasmaPathPayloadTest is
  PayloadEthereumScript,
  BaseAddPlasmaPathPayloadTest('ethereum', 23343028)
{
  function _getDeployedPayload() internal pure override returns (address) {
    return 0xBD770E618C49d151959d596D5d2770F0f3301a7b;
  }

  function _getCurrentNetworkAddresses() internal view override returns (Addresses memory) {
    return _getAddresses(TRANSACTION_NETWORK());
  }

  function _getPayload() internal override returns (address) {
    Addresses memory currentAddresses = _getCurrentNetworkAddresses();

    AddForwarderAdapterArgs memory args = AddForwarderAdapterArgs({
      crossChainController: currentAddresses.crossChainController,
      currentChainHLBridgeAdapter: 0x6bda311748E6542d578b167d791A4130f3FbBc67,
      destinationChainHLBridgeAdapter: 0x13Dc9eBb19bb1A14aa56215b443B2703A07ba2D5,
      currentChainCCIPBridgeAdapter: 0x352C71092fB60ce2f94DFF4ACda330DdffD946B0,
      destinationChainCCIPBridgeAdapter: 0x719e23D7B48Fc5AEa65Cff1bc58865C2b8d89A34,
      currentChainLZBridgeAdapter: 0xBA0Ee375e9d0c815097D9eB7EB9Db20b59c06792,
      destinationChainLZBridgeAdapter: 0x99950E7C7eB320A8551916e8676a42b90b058d5D,
      destinationChainId: DESTINATION_CHAIN_ID()
    });
    return _deployPayload(args);
  }
}
