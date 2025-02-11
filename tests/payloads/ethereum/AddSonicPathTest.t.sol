// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/console.sol';
import {ADITestBase} from '../../adi/ADITestBase.sol';
import { Addresses, Ethereum as PayloadEthereumScript} from '../../../scripts/payloads/adapters/ethereum/Network_Deployments.s.sol';
import {Ethereum_Sonic_Path_Payload, AddForwarderAdapterArgs} from '../../../src/adapter_payloads/Ethereum_Sonic_Path_Payload.sol';

abstract contract BaseAddSonicPathPayloadTest is ADITestBase {
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
      string.concat('add_sonic_path_to_adi', NETWORK),
      _crossChainController,
      address(_payload),
      false,
      vm
    );
  }

  function test_samePayloadAddress(
  ) public {
    Ethereum_Sonic_Path_Payload deployedPayload = Ethereum_Sonic_Path_Payload(_getDeployedPayload());
    Ethereum_Sonic_Path_Payload predictedPayload = Ethereum_Sonic_Path_Payload(_getPayload());

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

contract EthereumAddSonicPathPayloadTest is
  PayloadEthereumScript,
  BaseAddSonicPathPayloadTest('ethereum', 21824382) 
{
  function _getDeployedPayload() internal pure override returns (address) {
    return 0x41FE455778201FB3AC7E41a7b2B4ffC90F08035e;
  }

  function _getCurrentNetworkAddresses() internal view override returns (Addresses memory) {
    return _getAddresses(TRANSACTION_NETWORK());
  }

  function _getPayload() internal override returns (address) {
    Addresses memory currentAddresses = _getCurrentNetworkAddresses();

    AddForwarderAdapterArgs memory args = AddForwarderAdapterArgs({
      crossChainController: currentAddresses.crossChainController,
      currentChainHLBridgeAdapter: 0x01dcb90Cf13b82Cde4A0BAcC655585a83Af3cCC1,
      destinationChainHLBridgeAdapter: 0x1098F187F5f444Bc1c77cD9beE99e8d460347F5F,
      currentChainCCIPBridgeAdapter: 0xe3a0d9754aD3452D687cf580Ba3674c2D7D2f7AE,
      destinationChainCCIPBridgeAdapter: 0x1905fCdDa41241C0871A5eC3f9dcC3E8d247261D,
      currentChainLZBridgeAdapter: 0x8FD7D8dd557817966181F584f2abB53549B4ABbe,
      destinationChainLZBridgeAdapter: 0x7B8FaC105A7a85f02C3f31559d2ee7313BDC5d7f,
      destinationChainId: DESTINATION_CHAIN_ID()
    });
    return _deployPayload(args);
  }
}
