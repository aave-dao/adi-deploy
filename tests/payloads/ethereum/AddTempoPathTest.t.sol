// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Vm} from 'forge-std/Vm.sol';
import {ADITestBase} from '../../adi/ADITestBase.sol';
import {TempoPathHelpers, EthereumTempoCCIPCode, EthereumTempoHLCode, EthereumTempoWormholeCode} from '../../tempo/TempoPathHelpers.sol';
import {Create2Utils} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {ChainIds} from 'solidity-utils/contracts/utils/ChainHelpers.sol';
import {ICrossChainForwarder} from 'adi/interfaces/ICrossChainForwarder.sol';
import {IBaseAdapter} from 'adi/adapters/IBaseAdapter.sol';
import {Addresses, Ethereum_Tempo as PayloadEthereumTempoScript} from '../../../scripts/payloads/adapters/ethereum/Network_Deployments.s.sol';
import {Ethereum_Tempo_Path_Payload} from '../../../src/adapter_payloads/Ethereum_Tempo_Path_Payload.sol';

interface IOwnable {
  function owner() external view returns (address);
}

/**
 * @dev nothing is deployed yet: the new Ethereum adapters are deployed on the fork from their scripts,
 * and the Tempo CCC and adapters are predicted from theirs (see TempoPathHelpers)
 */
contract EthereumAddTempoPathPayloadTest is
  PayloadEthereumTempoScript,
  ADITestBase,
  TempoPathHelpers
{
  uint256 internal constant BLOCK_NUMBER = 26477900;

  address internal _payload;
  Addresses internal _ethereum;
  Addresses internal _tempo;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('ethereum'), BLOCK_NUMBER);

    _tempo = _predictTempoAddresses();

    _ethereum = _getAddresses(ChainIds.ETHEREUM);
    _ethereum.ccipAdapter = Create2Utils.create2Deploy(
      ADAPTER_SALT,
      new EthereumTempoCCIPCode(_tempo.crossChainController).getAdapterCode()
    );
    _ethereum.hlAdapter = Create2Utils.create2Deploy(
      ADAPTER_SALT,
      new EthereumTempoHLCode(_tempo.crossChainController).getAdapterCode()
    );
    _ethereum.wormholeExecutorAdapter = Create2Utils.create2Deploy(
      ADAPTER_SALT,
      new EthereumTempoWormholeCode(_tempo.crossChainController).getAdapterCode()
    );

    _payload = _deployPayload(_getPayloadArgs(_ethereum, _tempo));
  }

  function test_defaultTest() public {
    defaultTest('add_tempo_path_to_adiethereum', ETHEREUM_CCC, _payload, false, vm);
  }

  function test_payloadConfig() public view {
    Ethereum_Tempo_Path_Payload payload = Ethereum_Tempo_Path_Payload(_payload);
    assertEq(payload.CROSS_CHAIN_CONTROLLER(), ETHEREUM_CCC);
    assertEq(payload.DESTINATION_CHAIN_ID(), ChainIds.TEMPO);
    assertEq(payload.CURRENT_CHAIN_CCIP_BRIDGE_ADAPTER(), _ethereum.ccipAdapter);
    assertEq(payload.DESTINATION_CHAIN_CCIP_BRIDGE_ADAPTER(), _tempo.ccipAdapter);
    assertEq(payload.CURRENT_CHAIN_HL_BRIDGE_ADAPTER(), _ethereum.hlAdapter);
    assertEq(payload.DESTINATION_CHAIN_HL_BRIDGE_ADAPTER(), _tempo.hlAdapter);
    assertEq(
      payload.CURRENT_CHAIN_WORMHOLE_EXECUTOR_BRIDGE_ADAPTER(),
      _ethereum.wormholeExecutorAdapter
    );
    assertEq(
      payload.DESTINATION_CHAIN_WORMHOLE_EXECUTOR_BRIDGE_ADAPTER(),
      _tempo.wormholeExecutorAdapter
    );
  }

  /// @dev the new adapters have the Tempo settings and replace the current Ethereum adapters in ethereum.json
  function test_newEthereumAdapters() public {
    address[3] memory adapters = [
      _ethereum.ccipAdapter,
      _ethereum.hlAdapter,
      _ethereum.wormholeExecutorAdapter
    ];
    for (uint256 i = 0; i < adapters.length; i++) {
      IBaseAdapter adapter = IBaseAdapter(adapters[i]);
      assertEq(adapter.BASE_GAS_LIMIT(), 700_000);
      assertEq(address(adapter.CROSS_CHAIN_CONTROLLER()), ETHEREUM_CCC);
      assertEq(adapter.getTrustedRemoteByChainId(ChainIds.TEMPO), _tempo.crossChainController);
      assertTrue(adapter.infraToNativeChainId(ChainIds.TEMPO) != 0);
    }
    assertEq(
      IBaseAdapter(_ethereum.ccipAdapter).infraToNativeChainId(ChainIds.TEMPO),
      7281642695469137430
    );
    assertEq(IBaseAdapter(_ethereum.hlAdapter).infraToNativeChainId(ChainIds.TEMPO), 4217);
    assertEq(
      IBaseAdapter(_ethereum.wormholeExecutorAdapter).infraToNativeChainId(ChainIds.TEMPO),
      68
    );

    assertTrue(_ethereum.ccipAdapter != _getAddresses(ChainIds.ETHEREUM).ccipAdapter);
    assertTrue(_ethereum.hlAdapter != _getAddresses(ChainIds.ETHEREUM).hlAdapter);
    assertTrue(
      _ethereum.wormholeExecutorAdapter != _getAddresses(ChainIds.ETHEREUM).wormholeExecutorAdapter
    );
  }

  function test_pathEnabledWithBandwidth() public {
    assertEq(
      ICrossChainForwarder(ETHEREUM_CCC).getForwarderBridgeAdaptersByChain(ChainIds.TEMPO).length,
      0
    );

    executePayload(vm, _payload);

    ICrossChainForwarder.ChainIdBridgeConfig[] memory forwarders = ICrossChainForwarder(
      ETHEREUM_CCC
    ).getForwarderBridgeAdaptersByChain(ChainIds.TEMPO);
    assertEq(forwarders.length, 3);
    assertEq(forwarders[0].currentChainBridgeAdapter, _ethereum.ccipAdapter);
    assertEq(forwarders[0].destinationBridgeAdapter, _tempo.ccipAdapter);
    assertEq(forwarders[1].currentChainBridgeAdapter, _ethereum.hlAdapter);
    assertEq(forwarders[1].destinationBridgeAdapter, _tempo.hlAdapter);
    assertEq(forwarders[2].currentChainBridgeAdapter, _ethereum.wormholeExecutorAdapter);
    assertEq(forwarders[2].destinationBridgeAdapter, _tempo.wormholeExecutorAdapter);
    assertEq(ICrossChainForwarder(ETHEREUM_CCC).getOptimalBandwidthByChain(ChainIds.TEMPO), 2);
  }

  /// @dev a governance-sized message to Tempo goes out through 2 of the 3 bridges (optimal bandwidth)
  function test_forwardToTempo() public {
    executePayload(vm, _payload);
    // the Hyperlane hooks use cancun opcodes, which the shanghai profile EVM rejects
    vm.setEvmVersion('cancun');

    address owner = IOwnable(ETHEREUM_CCC).owner();
    address[] memory senders = new address[](1);
    senders[0] = address(this);
    vm.prank(owner);
    ICrossChainForwarder(ETHEREUM_CCC).approveSenders(senders);

    vm.recordLogs();
    ICrossChainForwarder(ETHEREUM_CCC).forwardMessage(
      ChainIds.TEMPO,
      address(this),
      300_000,
      abi.encode(uint40(1), uint8(1), uint40(block.timestamp))
    );

    Vm.Log[] memory logs = vm.getRecordedLogs();
    bytes32 topic = ICrossChainForwarder.TransactionForwardingAttempted.selector;
    uint256 attempts;
    for (uint256 i = 0; i < logs.length; i++) {
      if (logs[i].topics.length == 0 || logs[i].topics[0] != topic) continue;
      attempts++;
      assertEq(uint256(logs[i].topics[3]), 1, 'bridge adapter forwarding failed');
    }
    assertEq(attempts, 2);
  }
}
