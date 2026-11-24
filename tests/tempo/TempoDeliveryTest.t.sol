// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {Create2Utils} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {ChainIds} from 'solidity-utils/contracts/utils/ChainHelpers.sol';
import {TransparentProxyFactory} from 'solidity-utils/contracts/transparent-proxy/TransparentProxyFactory.sol';
import {ICrossChainReceiver} from 'adi/interfaces/ICrossChainReceiver.sol';
import {Envelope, EnvelopeUtils, EncodedEnvelope, Transaction, TransactionUtils, EncodedTransaction} from 'adi/libs/EncodingUtils.sol';
import {CCIPAdapter} from 'adi/adapters/ccip/CCIPAdapter.sol';
import {Client} from 'adi/adapters/ccip/lib/Client.sol';
import {HyperLaneAdapter} from 'adi/adapters/hyperLane/HyperLaneAdapter.sol';
import {WormholeExecutorAdapter} from 'adi/adapters/wormhole/WormholeExecutorAdapter.sol';
import {MockDestination} from 'adi-scripts/contract_extensions/MockDestination.sol';
import {Addresses} from '../../scripts/BaseDeployerScript.sol';
import {Tempo as TempoReceiversScript} from '../../scripts/ccc/Set_CCR_Receivers_Adapters.s.sol';
import {Tempo as TempoConfirmationsScript, BaseSetCCRConfirmations} from '../../scripts/ccc/Set_CCR_Confirmations.s.sol';
import {TempoPathHelpers, TempoCCCDeployer} from './TempoPathHelpers.sol';

/**
 * @dev deploys the Tempo side of the Ethereum -> Tempo path on a Tempo fork with the repo scripts, then delivers
 * an Ethereum message through each bridge's receive entry point (CCIP router -> ccipReceive, Hyperlane Mailbox ->
 * handle, Wormhole Executor relayer -> executeVAAv1 with a really verified VAA). For each bridge it finds the
 * smallest gas limit with which that call succeeds, both as the first confirmation and as the confirmation that
 * reaches the 2-of-3 threshold and forwards the envelope to the destination. The bridges deliver with the
 * Ethereum adapter's BASE_GAS_LIMIT plus the governance gas limit, so that is the budget checked here.
 *
 * forge-config: default.networks.network = "tempo"
 */
contract TempoDeliveryTest is Test, TempoPathHelpers {
  enum Bridge {
    CCIP,
    Hyperlane,
    Wormhole
  }

  struct Call {
    address caller;
    address target;
    bytes data;
  }

  uint256 internal constant TEMPO_BLOCK_NUMBER = 50432000;
  uint256 internal constant GOVERNANCE_GAS_LIMIT = 300_000;
  uint256 internal constant GUARDIAN_COUNT = 19;
  uint256 internal constant GUARDIAN_QUORUM = 13;
  uint32 internal constant GUARDIAN_SET_INDEX = 7;

  Addresses internal _tempo;
  address internal _destination;
  uint256 internal _nonce;

  function setUp() public virtual {
    vm.createSelectFork(vm.rpcUrl('tempo'), TEMPO_BLOCK_NUMBER);

    // CCC, through scripts/ccc/DeployCCC.s.sol:Tempo
    _tempo = new TempoCCCDeployer().deploy(_tempoBaseAddresses());

    // adapters, from scripts/adapters/Deploy{CCIPAdapter,HL,WormholeExecutor}.s.sol:Tempo
    _tempo.ccipAdapter = Create2Utils.create2Deploy(
      ADAPTER_SALT,
      _tempoCCIPAdapterCode(_tempo.crossChainController)
    );
    _tempo.hlAdapter = Create2Utils.create2Deploy(
      ADAPTER_SALT,
      _tempoHLAdapterCode(_tempo.crossChainController)
    );
    _tempo.wormholeExecutorAdapter = Create2Utils.create2Deploy(
      ADAPTER_SALT,
      _tempoWormholeAdapterCode(_tempo.crossChainController)
    );

    _configureReceiver();
    _destination = _deployDestination(_tempo.crossChainController);
    _useTestGuardians();
  }

  // ------------------------------------------------------------------------------------------------------------
  // hooks, overridden to measure delivery into a real PayloadsController
  // ------------------------------------------------------------------------------------------------------------

  function _deployDestination(address crossChainController) internal virtual returns (address) {
    return address(new MockDestination(crossChainController));
  }

  function _envelopeOrigin() internal view virtual returns (address) {
    return address(this);
  }

  /// @dev same shape as a governance message: (payloadId, accessLevel, proposalVoteActivationTimestamp)
  function _nextMessage() internal virtual returns (bytes memory) {
    return abi.encode(uint40(0), uint8(1), uint40(block.timestamp));
  }

  /// @dev checked after the envelope is delivered
  function _assertDestinationUpdated() internal view virtual {}

  // ------------------------------------------------------------------------------------------------------------
  // tests
  // ------------------------------------------------------------------------------------------------------------

  /// @dev the Ethereum payload test relies on these predictions
  function test_predictedAddresses() public {
    Addresses memory predicted = _predictTempoAddresses();
    assertEq(_tempo.crossChainController, predicted.crossChainController);
    assertEq(
      TransparentProxyFactory(TEMPO_PROXY_FACTORY).predictCreateDeterministic(
        _predictTempoCCCImpl(),
        TEMPO_EXECUTOR,
        _tempoCCCInitData(),
        CCC_SALT
      ),
      _tempo.crossChainController
    );
    assertEq(_tempo.crossChainControllerImpl, _predictTempoCCCImpl());
    assertEq(_tempo.ccipAdapter, predicted.ccipAdapter);
    assertEq(_tempo.hlAdapter, predicted.hlAdapter);
    assertEq(_tempo.wormholeExecutorAdapter, predicted.wormholeExecutorAdapter);
  }

  function test_receiverConfig() public view {
    ICrossChainReceiver ccc = ICrossChainReceiver(_tempo.crossChainController);
    assertEq(ccc.getConfigurationByChain(ChainIds.ETHEREUM).requiredConfirmation, 2);
    address[] memory receivers = ccc.getReceiverBridgeAdaptersByChain(ChainIds.ETHEREUM);
    assertEq(receivers.length, 3);
    assertTrue(ccc.isReceiverBridgeAdapterAllowed(_tempo.ccipAdapter, ChainIds.ETHEREUM));
    assertTrue(ccc.isReceiverBridgeAdapterAllowed(_tempo.hlAdapter, ChainIds.ETHEREUM));
    assertTrue(
      ccc.isReceiverBridgeAdapterAllowed(_tempo.wormholeExecutorAdapter, ChainIds.ETHEREUM)
    );
  }

  /// @dev any 2 of the 3 bridges deliver the envelope
  function test_twoOfThreeDeliver() public {
    for (uint256 first = 0; first < 3; first++) {
      for (uint256 second = 0; second < 3; second++) {
        if (first == second) continue;
        uint256 snapshot = vm.snapshotState();
        (
          EncodedTransaction memory transaction,
          EncodedEnvelope memory envelope
        ) = _newTransaction();

        assertTrue(_call(_receiveCall(Bridge(first), transaction.data), type(uint64).max));
        // one confirmation is not enough
        assertEq(
          uint8(ICrossChainReceiver(_tempo.crossChainController).getEnvelopeState(envelope.id)),
          uint8(ICrossChainReceiver.EnvelopeState.None)
        );

        assertTrue(_call(_receiveCall(Bridge(second), transaction.data), type(uint64).max));
        assertEq(
          uint8(ICrossChainReceiver(_tempo.crossChainController).getEnvelopeState(envelope.id)),
          uint8(ICrossChainReceiver.EnvelopeState.Delivered)
        );
        _assertDestinationUpdated();
        vm.revertToState(snapshot);
      }
    }
  }

  function test_deliveryGas() public {
    uint256 budget = 700_000 + GOVERNANCE_GAS_LIMIT;
    string[3] memory names = ['CCIP', 'Hyperlane', 'Wormhole Executor'];

    for (uint256 b = 0; b < 3; b++) {
      (uint256 firstGas, uint256 finalGas) = _measure(Bridge(b));
      console.log(names[b]);
      console.log('  min gas, first confirmation:', firstGas);
      console.log('  min gas, final confirmation + delivery:', finalGas);
      assertLe(firstGas, budget, 'first confirmation exceeds the bridge gas limit');
      assertLe(finalGas, budget, 'final confirmation exceeds the bridge gas limit');
    }
    console.log('bridge gas limit (base + governance):', budget);
  }

  // ------------------------------------------------------------------------------------------------------------
  // measurement
  // ------------------------------------------------------------------------------------------------------------

  /// @return firstGas smallest gas with which `bridge` records the first confirmation
  /// @return finalGas smallest gas with which `bridge` brings the second confirmation and the envelope is delivered
  function _measure(Bridge bridge) internal returns (uint256 firstGas, uint256 finalGas) {
    uint256 snapshot = vm.snapshotState();
    (EncodedTransaction memory transaction, EncodedEnvelope memory envelope) = _newTransaction();
    Call memory call = _receiveCall(bridge, transaction.data);
    address adapter = call.target;

    firstGas = _minGas(call, adapter, transaction.id, bytes32(0));

    // another bridge confirms first, then `bridge` completes the threshold
    Bridge other = Bridge((uint256(bridge) + 1) % 3);
    _call(_receiveCall(other, transaction.data), type(uint64).max);
    finalGas = _minGas(call, adapter, transaction.id, envelope.id);

    // and the measured gas really delivers
    _cool(call.target);
    _call(call, finalGas);
    assertEq(
      uint8(ICrossChainReceiver(_tempo.crossChainController).getEnvelopeState(envelope.id)),
      uint8(ICrossChainReceiver.EnvelopeState.Delivered)
    );
    _assertDestinationUpdated();

    vm.revertToState(snapshot);
  }

  /// @dev binary search on the call's gas limit, each probe from the same state with cold storage
  function _minGas(
    Call memory call,
    address adapter,
    bytes32 transactionId,
    bytes32 envelopeId
  ) internal returns (uint256) {
    uint256 low = 21_000;
    uint256 high = 10_000_000;
    while (high - low > 500) {
      uint256 mid = (low + high) / 2;
      uint256 snapshot = vm.snapshotState();
      _cool(call.target);
      bool ok = _call(call, mid) &&
        ICrossChainReceiver(_tempo.crossChainController).isTransactionReceivedByAdapter(
          transactionId,
          adapter
        ) &&
        (envelopeId == bytes32(0) ||
          ICrossChainReceiver(_tempo.crossChainController).getEnvelopeState(envelopeId) ==
          ICrossChainReceiver.EnvelopeState.Delivered);
      vm.revertToState(snapshot);
      if (ok) high = mid;
      else low = mid;
    }
    return high;
  }

  function _call(Call memory call, uint256 gasLimit) internal returns (bool ok) {
    vm.prank(call.caller);
    (ok, ) = call.target.call{gas: gasLimit}(call.data);
  }

  /// @dev every account a delivery touches starts cold, as in a fresh transaction
  function _cool(address adapter) internal {
    address[] memory accounts = new address[](8);
    accounts[0] = adapter;
    accounts[1] = _tempo.crossChainController;
    accounts[2] = _implementation(_tempo.crossChainController);
    accounts[3] = _destination;
    accounts[4] = _implementation(_destination);
    accounts[5] = TEMPO_WORMHOLE_CORE;
    accounts[6] = _implementation(TEMPO_WORMHOLE_CORE);
    accounts[7] = TEMPO_CL_EMERGENCY_ORACLE;
    for (uint256 i = 0; i < accounts.length; i++) {
      if (accounts[i] != address(0)) vm.cool(accounts[i]);
    }
  }

  function _implementation(address proxy) internal view returns (address) {
    return
      address(
        uint160(
          uint256(
            vm.load(proxy, 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)
          )
        )
      );
  }

  // ------------------------------------------------------------------------------------------------------------
  // messages
  // ------------------------------------------------------------------------------------------------------------

  function _newTransaction()
    internal
    returns (EncodedTransaction memory transaction, EncodedEnvelope memory envelope)
  {
    _nonce++;
    envelope = EnvelopeUtils.encode(
      Envelope({
        nonce: 1_000_000 + _nonce,
        origin: _envelopeOrigin(),
        destination: _destination,
        originChainId: ChainIds.ETHEREUM,
        destinationChainId: ChainIds.TEMPO,
        message: _nextMessage()
      })
    );
    transaction = TransactionUtils.encode(
      Transaction({nonce: 2_000_000 + _nonce, encodedEnvelope: envelope.data})
    );
  }

  function _receiveCall(
    Bridge bridge,
    bytes memory encodedTransaction
  ) internal view returns (Call memory) {
    if (bridge == Bridge.CCIP) {
      return
        Call({
          caller: TEMPO_CCIP_ROUTER,
          target: _tempo.ccipAdapter,
          data: abi.encodeCall(
            CCIPAdapter.ccipReceive,
            (
              Client.Any2EVMMessage({
                messageId: keccak256(encodedTransaction),
                sourceChainSelector: CCIP_SELECTOR_ETHEREUM,
                sender: abi.encode(ETHEREUM_CCC),
                data: encodedTransaction,
                tokenAmounts: new Client.EVMTokenAmount[](0)
              })
            )
          )
        });
    } else if (bridge == Bridge.Hyperlane) {
      return
        Call({
          caller: TEMPO_HL_MAILBOX,
          target: _tempo.hlAdapter,
          data: abi.encodeCall(
            HyperLaneAdapter.handle,
            (uint32(ChainIds.ETHEREUM), bytes32(uint256(uint160(ETHEREUM_CCC))), encodedTransaction)
          )
        });
    }
    return
      Call({
        caller: address(0xE0E0),
        target: _tempo.wormholeExecutorAdapter,
        data: abi.encodeCall(WormholeExecutorAdapter.executeVAAv1, (_signedVAA(encodedTransaction)))
      });
  }

  // ------------------------------------------------------------------------------------------------------------
  // Wormhole: the Tempo Core verifies a VAA signed by 13 of 19 test guardians written into guardian set 7, so
  // the measured gas includes the real signature verification
  // ------------------------------------------------------------------------------------------------------------

  function _guardianKey(uint256 i) internal pure returns (uint256) {
    return uint256(keccak256(abi.encode('tempo test guardian', i)));
  }

  function _useTestGuardians() internal {
    // Wormhole Core storage: provider (slots 0-1), then mapping(uint32 => GuardianSet) guardianSets at slot 2
    bytes32 guardianSet = keccak256(abi.encode(uint256(GUARDIAN_SET_INDEX), uint256(2)));
    assertEq(uint256(vm.load(TEMPO_WORMHOLE_CORE, guardianSet)), GUARDIAN_COUNT);
    uint256 keys = uint256(keccak256(abi.encode(guardianSet)));
    for (uint256 i = 0; i < GUARDIAN_COUNT; i++) {
      vm.store(
        TEMPO_WORMHOLE_CORE,
        bytes32(keys + i),
        bytes32(uint256(uint160(vm.addr(_guardianKey(i)))))
      );
    }
  }

  function _signedVAA(bytes memory payload) internal view returns (bytes memory vaa) {
    bytes memory body = abi.encodePacked(
      uint32(block.timestamp),
      uint32(0),
      WORMHOLE_ID_ETHEREUM,
      bytes32(uint256(uint160(ETHEREUM_CCC))), // the adapter publishes via delegatecall from the CCC
      uint64(_nonce),
      uint8(202),
      payload
    );
    bytes32 digest = keccak256(abi.encodePacked(keccak256(body)));

    vaa = abi.encodePacked(uint8(1), GUARDIAN_SET_INDEX, uint8(GUARDIAN_QUORUM));
    for (uint256 i = 0; i < GUARDIAN_QUORUM; i++) {
      (uint8 v, bytes32 r, bytes32 s) = vm.sign(_guardianKey(i), digest);
      vaa = abi.encodePacked(vaa, uint8(i), r, s, uint8(v - 27));
    }
    vaa = abi.encodePacked(vaa, body);
  }

  // ------------------------------------------------------------------------------------------------------------

  /// @dev through scripts/ccc/Set_CCR_Receivers_Adapters.s.sol:Tempo and Set_CCR_Confirmations.s.sol:Tempo
  function _configureReceiver() internal {
    TempoReceiversScript receivers = new TempoReceiversScript();
    uint256[] memory chainIds = receivers.getChainIds();
    address[] memory adapters = receivers.getReceiverBridgeAdaptersToAllow(_tempo);
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory receiverConfig = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](
        adapters.length
      );
    for (uint256 i = 0; i < adapters.length; i++) {
      receiverConfig[i] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
        bridgeAdapter: adapters[i],
        chainIds: chainIds
      });
    }

    BaseSetCCRConfirmations.ConfirmationsByChain[]
      memory confirmations = new TempoConfirmationsScript().getConfirmationsByChainIds();
    ICrossChainReceiver.ConfirmationInput[]
      memory confirmationInput = new ICrossChainReceiver.ConfirmationInput[](confirmations.length);
    for (uint256 i = 0; i < confirmations.length; i++) {
      confirmationInput[i] = ICrossChainReceiver.ConfirmationInput({
        chainId: confirmations[i].chainId,
        requiredConfirmations: confirmations[i].confirmations
      });
    }

    vm.startPrank(TEMPO_DEPLOYER);
    ICrossChainReceiver(_tempo.crossChainController).allowReceiverBridgeAdapters(receiverConfig);
    ICrossChainReceiver(_tempo.crossChainController).updateConfirmations(confirmationInput);
    vm.stopPrank();
  }
}
