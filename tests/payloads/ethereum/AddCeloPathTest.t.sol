// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/console.sol';
import {ADITestBase} from '../../adi/ADITestBase.sol';
import { Addresses, Ethereum as PayloadEthereumScript} from '../../../scripts/payloads/adapters/ethereum/Network_Deployments.s.sol';
import {Ethereum_Celo_Path_Payload, AddForwarderAdapterArgs} from '../../../src/adapter_payloads/Ethereum_Celo_Path_Payload.sol';

abstract contract BaseAddCeloPathPayloadTest is ADITestBase {
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
      string.concat('add_celo_path_to_adi', NETWORK),
      _crossChainController,
      address(_payload),
      false,
      vm
    );
  }

  function test_samePayloadAddress(
  ) public {
    Ethereum_Celo_Path_Payload deployedPayload = Ethereum_Celo_Path_Payload(_getDeployedPayload());
    Ethereum_Celo_Path_Payload predictedPayload = Ethereum_Celo_Path_Payload(_getPayload());

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

contract EthereumAddCeloPathPayloadTest is
  PayloadEthereumScript,
  BaseAddCeloPathPayloadTest('ethereum', 21586373)
{
  function _getDeployedPayload() internal pure override returns (address) {
    return 0x8F7E2023686B78E148e65004Ca8AcEf9B2B46922;
  }

  function _getCurrentNetworkAddresses() internal view override returns (Addresses memory) {
    return _getAddresses(TRANSACTION_NETWORK());
  }

  function _getPayload() internal override returns (address) {
    Addresses memory currentAddresses = _getCurrentNetworkAddresses();

    AddForwarderAdapterArgs memory args = AddForwarderAdapterArgs({
      crossChainController: currentAddresses.crossChainController,
      currentChainHLBridgeAdapter: 0x01dcb90Cf13b82Cde4A0BAcC655585a83Af3cCC1,
      destinationChainHLBridgeAdapter: 0x7b065E68E70f346B18636Ab86779980287ec73e0,
      currentChainCCIPBridgeAdapter: 0x58489B249BfBCF5ef4B30bdE2792086e83122B6f,
      destinationChainCCIPBridgeAdapter: 0x3d534E8964e7aAcfc702751cc9A2BB6A9fe7d928,
      currentChainLZBridgeAdapter: 0x8410d9BD353b420ebA8C48ff1B0518426C280FCC,
      destinationChainLZBridgeAdapter: 0x83BC62fbeA15B7Bfe11e8eEE57997afA5451f38C,
      destinationChainId: DESTINATION_CHAIN_ID()
    });
    return _deployPayload(args);
  }
}
