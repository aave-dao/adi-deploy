// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Vm} from 'forge-std/Vm.sol';
import {ADITestBase} from '../../adi/ADITestBase.sol';
import {Create2Utils} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {ChainIds} from 'solidity-utils/contracts/utils/ChainHelpers.sol';
import {ICrossChainForwarder} from 'adi/interfaces/ICrossChainForwarder.sol';
import {ICrossChainReceiver} from 'adi/interfaces/ICrossChainReceiver.sol';
import {Envelope, EnvelopeUtils, Transaction, TransactionUtils, EncodedTransaction} from 'adi/libs/EncodingUtils.sol';
import {ICoreBridge, CoreBridgeVM, GuardianSignature} from 'adi/adapters/wormhole/interfaces/ICoreBridge.sol';
import {IWormholeExecutorAdapter} from 'adi/adapters/wormhole/IWormholeExecutorAdapter.sol';
import {WormholeExecutorAdapter} from 'adi/adapters/wormhole/WormholeExecutorAdapter.sol';
import {CCIPAdapter} from 'adi/adapters/ccip/CCIPAdapter.sol';
import {Client} from 'adi/adapters/ccip/lib/Client.sol';
import {IExecutor} from 'aave-address-book/governance-v3/IExecutor.sol';
import {Addresses, Ethereum as EthereumPayloadScript, Polygon as PolygonPayloadScript, Avalanche as AvalanchePayloadScript, Binance as BinancePayloadScript, Monad as MonadPayloadScript, Gnosis as GnosisPayloadScript} from '../../../scripts/payloads/adapters/replace_lz/Network_Deployments.s.sol';
import {Ethereum as EthereumWormholeExecutor, Polygon as PolygonWormholeExecutor, Avalanche as AvalancheWormholeExecutor, Binance as BinanceWormholeExecutor, Monad as MonadWormholeExecutor} from '../../../scripts/adapters/DeployWormholeExecutor.s.sol';
import {Ethereum_Gnosis as EthereumGnosisCCIP, Gnosis as GnosisCCIP} from '../../../scripts/adapters/DeployCCIPAdapter.s.sol';

interface IOwnable {
  function owner() external view returns (address);
}

/// @dev CREATE2 addresses of the new adapters, computed from the deploy scripts' bytecode
abstract contract ReplaceLZAdapters {
  bytes32 internal constant ADAPTER_SALT = keccak256(abi.encode('a.DI Adapter'));

  // Wormhole chain ids, from wormhole-foundation/wormhole sdk/vaa/structs.go
  uint16 internal constant WORMHOLE_ID_ETHEREUM = 2;
  uint16 internal constant WORMHOLE_ID_POLYGON = 5;
  uint16 internal constant WORMHOLE_ID_AVALANCHE = 6;

  // CCIP chain selector, from the Chainlink CCIP directory
  uint64 internal constant CCIP_SELECTOR_ETHEREUM = 5009297550715157269;

  function _wormholeExecutorAdapterCode(uint256 chainId) internal returns (bytes memory) {
    if (chainId == ChainIds.ETHEREUM) return new EthereumWormholeExecutor().getAdapterCode();
    if (chainId == ChainIds.POLYGON) return new PolygonWormholeExecutor().getAdapterCode();
    if (chainId == ChainIds.AVALANCHE) return new AvalancheWormholeExecutor().getAdapterCode();
    if (chainId == ChainIds.BNB) return new BinanceWormholeExecutor().getAdapterCode();
    if (chainId == ChainIds.MONAD) return new MonadWormholeExecutor().getAdapterCode();
    revert('no wormhole executor adapter for chain');
  }

  function _gnosisPathCCIPAdapterCode(uint256 chainId) internal returns (bytes memory) {
    if (chainId == ChainIds.ETHEREUM) return new EthereumGnosisCCIP().getAdapterCode();
    if (chainId == ChainIds.GNOSIS) return new GnosisCCIP().getAdapterCode();
    revert('no gnosis path ccip adapter for chain');
  }

  function _predict(bytes memory code) internal pure returns (address) {
    return Create2Utils.computeCreate2Address(ADAPTER_SALT, code);
  }

  function _deploy(bytes memory code) internal returns (address) {
    return Create2Utils.create2Deploy(ADAPTER_SALT, code);
  }
}

abstract contract BaseReplaceLZTest is ADITestBase, ReplaceLZAdapters {
  struct ReceiverSwap {
    uint256 originChainId;
    address oldAdapter;
    address newAdapter;
  }

  struct ForwarderSwap {
    uint256 destinationChainId;
    address oldCurrentAdapter;
    address newCurrentAdapter;
    address newDestinationAdapter;
  }

  string internal NETWORK;
  uint256 internal immutable BLOCK_NUMBER;

  address internal _crossChainController;
  address internal _payload;

  mapping(uint256 => address) internal _wormholeExecutorAdapters;
  mapping(uint256 => address) internal _gnosisPathCCIPAdapters;

  constructor(string memory network, uint256 blockNumber) {
    NETWORK = network;
    BLOCK_NUMBER = blockNumber;
  }

  function _currentChainId() internal pure virtual returns (uint256);

  /// @dev deploys this chain's new adapters on the fork and predicts the remote ones
  function _setUpAdapters() internal virtual;

  function _buildPayload() internal virtual returns (address);

  function _receiverSwaps() internal view virtual returns (ReceiverSwap[] memory);

  function _forwarderSwaps() internal view virtual returns (ForwarderSwap[] memory) {
    return new ForwarderSwap[](0);
  }

  /// @dev delivers a message from `swap.originChainId` through `swap.newAdapter`
  function _deliver(ReceiverSwap memory swap, bytes memory encodedTransaction) internal virtual;

  function setUp() public {
    _fork();
    _crossChainController = getCCCByChainId(_currentChainId());
    _setUpAdapters();
    _payload = _buildPayload();
  }

  function _fork() internal virtual {
    vm.createSelectFork(vm.rpcUrl(NETWORK), BLOCK_NUMBER);
  }

  function test_defaultTest() public {
    defaultTest(string.concat('replace_lz_', NETWORK), _crossChainController, _payload, false, vm);
  }

  function test_receiversSwappedWithUnchangedConfirmations() public {
    ReceiverSwap[] memory swaps = _receiverSwaps();
    uint256[] memory countsBefore = new uint256[](swaps.length);
    uint8[] memory confirmationsBefore = new uint8[](swaps.length);
    for (uint256 i = 0; i < swaps.length; i++) {
      countsBefore[i] = _receiverAdapters(swaps[i].originChainId).length;
      confirmationsBefore[i] = _requiredConfirmations(swaps[i].originChainId);
      assertTrue(_isReceiverAllowed(swaps[i].oldAdapter, swaps[i].originChainId));
      assertFalse(_isReceiverAllowed(swaps[i].newAdapter, swaps[i].originChainId));
    }

    executePayload(vm, _payload);

    for (uint256 i = 0; i < swaps.length; i++) {
      assertFalse(_isReceiverAllowed(swaps[i].oldAdapter, swaps[i].originChainId));
      assertTrue(_isReceiverAllowed(swaps[i].newAdapter, swaps[i].originChainId));
      assertEq(_receiverAdapters(swaps[i].originChainId).length, countsBefore[i]);
      assertEq(_requiredConfirmations(swaps[i].originChainId), confirmationsBefore[i]);
    }
  }

  function test_forwardersSwappedWithUnchangedBandwidth() public {
    ForwarderSwap[] memory swaps = _forwarderSwaps();
    uint256[] memory countsBefore = new uint256[](swaps.length);
    uint256[] memory bandwidthBefore = new uint256[](swaps.length);
    for (uint256 i = 0; i < swaps.length; i++) {
      ICrossChainForwarder.ChainIdBridgeConfig[] memory forwarders = _forwarders(
        swaps[i].destinationChainId
      );
      countsBefore[i] = forwarders.length;
      bandwidthBefore[i] = _bandwidth(swaps[i].destinationChainId);
      assertTrue(_hasCurrentAdapter(forwarders, swaps[i].oldCurrentAdapter));
    }

    executePayload(vm, _payload);

    for (uint256 i = 0; i < swaps.length; i++) {
      ICrossChainForwarder.ChainIdBridgeConfig[] memory forwarders = _forwarders(
        swaps[i].destinationChainId
      );
      assertFalse(_hasCurrentAdapter(forwarders, swaps[i].oldCurrentAdapter));
      assertTrue(_hasPair(forwarders, swaps[i].newCurrentAdapter, swaps[i].newDestinationAdapter));
      assertEq(forwarders.length, countsBefore[i]);
      assertEq(_bandwidth(swaps[i].destinationChainId), bandwidthBefore[i]);
    }
  }

  /// @dev every adapter of the path, the new one included, must forward successfully
  function test_forwardThroughNewAdapters() public {
    ForwarderSwap[] memory swaps = _forwarderSwaps();
    executePayload(vm, _payload);
    // the Hyperlane hooks use cancun opcodes, which the shanghai profile EVM rejects
    vm.setEvmVersion('cancun');

    address owner = IOwnable(_crossChainController).owner();
    address[] memory senders = new address[](1);
    senders[0] = address(this);
    vm.prank(owner);
    ICrossChainForwarder(_crossChainController).approveSenders(senders);

    for (uint256 i = 0; i < swaps.length; i++) {
      // bandwidth 0 sends through every adapter, so the new one is always exercised
      ICrossChainForwarder.OptimalBandwidthByChain[]
        memory bandwidth = new ICrossChainForwarder.OptimalBandwidthByChain[](1);
      bandwidth[0] = ICrossChainForwarder.OptimalBandwidthByChain({
        chainId: swaps[i].destinationChainId,
        optimalBandwidth: 0
      });
      vm.prank(owner);
      ICrossChainForwarder(_crossChainController).updateOptimalBandwidthByChain(bandwidth);

      vm.recordLogs();
      ICrossChainForwarder(_crossChainController).forwardMessage(
        swaps[i].destinationChainId,
        address(this),
        300_000,
        abi.encode('replace lz')
      );
      _assertAllForwardingSucceeded(
        vm.getRecordedLogs(),
        _forwarders(swaps[i].destinationChainId).length,
        swaps[i].newCurrentAdapter
      );
    }
  }

  function test_receiveThroughNewAdapters() public {
    ReceiverSwap[] memory swaps = _receiverSwaps();
    executePayload(vm, _payload);

    for (uint256 i = 0; i < swaps.length; i++) {
      Envelope memory envelope = Envelope({
        nonce: 777 + i,
        origin: address(this),
        destination: address(this),
        originChainId: swaps[i].originChainId,
        destinationChainId: _currentChainId(),
        message: abi.encode('replace lz')
      });
      EncodedTransaction memory transaction = TransactionUtils.encode(
        Transaction({nonce: 777 + i, encodedEnvelope: EnvelopeUtils.encode(envelope).data})
      );

      _deliver(swaps[i], transaction.data);

      assertTrue(
        ICrossChainReceiver(_crossChainController).isTransactionReceivedByAdapter(
          transaction.id,
          swaps[i].newAdapter
        )
      );
      assertEq(
        ICrossChainReceiver(_crossChainController)
          .getTransactionState(transaction.id)
          .confirmations,
        1
      );
    }
  }

  function _deliverViaWormhole(
    ReceiverSwap memory swap,
    uint16 originWormholeChainId,
    bytes memory encodedTransaction
  ) internal {
    address core = IWormholeExecutorAdapter(swap.newAdapter).WORMHOLE_CORE();
    CoreBridgeVM memory vaa;
    vaa.emitterChainId = originWormholeChainId;
    // the adapter publishes via delegatecall, so the emitter is the origin CCC
    vaa.emitterAddress = bytes32(uint256(uint160(getCCCByChainId(swap.originChainId))));
    vaa.payload = encodedTransaction;
    vaa.signatures = new GuardianSignature[](0);
    // guardian signatures can't be produced on a fork; everything after verification is real
    vm.mockCall(
      core,
      abi.encodeWithSelector(ICoreBridge.parseAndVerifyVM.selector),
      abi.encode(vaa, true, '')
    );
    WormholeExecutorAdapter(payable(swap.newAdapter)).executeVAAv1(hex'01');
    vm.clearMockedCalls();
  }

  function _deliverViaCCIP(
    ReceiverSwap memory swap,
    uint64 originSelector,
    bytes memory encodedTransaction
  ) internal {
    CCIPAdapter adapter = CCIPAdapter(swap.newAdapter);
    vm.prank(address(adapter.CCIP_ROUTER()));
    adapter.ccipReceive(
      Client.Any2EVMMessage({
        messageId: keccak256(encodedTransaction),
        sourceChainSelector: originSelector,
        sender: abi.encode(getCCCByChainId(swap.originChainId)),
        data: encodedTransaction,
        tokenAmounts: new Client.EVMTokenAmount[](0)
      })
    );
  }

  function _assertAllForwardingSucceeded(
    Vm.Log[] memory logs,
    uint256 expectedAttempts,
    address expectedAdapter
  ) internal pure {
    bytes32 topic = ICrossChainForwarder.TransactionForwardingAttempted.selector;
    uint256 attempts;
    bool expectedAdapterUsed;
    for (uint256 i = 0; i < logs.length; i++) {
      if (logs[i].topics.length == 0 || logs[i].topics[0] != topic) continue;
      attempts++;
      address bridgeAdapter = address(uint160(uint256(logs[i].topics[2])));
      bool adapterSuccessful = uint256(logs[i].topics[3]) == 1;
      assertTrue(adapterSuccessful, 'bridge adapter forwarding failed');
      if (bridgeAdapter == expectedAdapter) expectedAdapterUsed = true;
    }
    assertEq(attempts, expectedAttempts);
    assertTrue(expectedAdapterUsed, 'new adapter not used');
  }

  function _receiverAdapters(uint256 chainId) internal view returns (address[] memory) {
    return ICrossChainReceiver(_crossChainController).getReceiverBridgeAdaptersByChain(chainId);
  }

  function _isReceiverAllowed(address adapter, uint256 chainId) internal view returns (bool) {
    return
      ICrossChainReceiver(_crossChainController).isReceiverBridgeAdapterAllowed(adapter, chainId);
  }

  function _requiredConfirmations(uint256 chainId) internal view returns (uint8) {
    return
      ICrossChainReceiver(_crossChainController)
        .getConfigurationByChain(chainId)
        .requiredConfirmation;
  }

  function _forwarders(
    uint256 chainId
  ) internal view returns (ICrossChainForwarder.ChainIdBridgeConfig[] memory) {
    return ICrossChainForwarder(_crossChainController).getForwarderBridgeAdaptersByChain(chainId);
  }

  function _bandwidth(uint256 chainId) internal view returns (uint256) {
    return ICrossChainForwarder(_crossChainController).getOptimalBandwidthByChain(chainId);
  }

  function _hasCurrentAdapter(
    ICrossChainForwarder.ChainIdBridgeConfig[] memory forwarders,
    address adapter
  ) internal pure returns (bool) {
    for (uint256 i = 0; i < forwarders.length; i++) {
      if (forwarders[i].currentChainBridgeAdapter == adapter) return true;
    }
    return false;
  }

  function _hasPair(
    ICrossChainForwarder.ChainIdBridgeConfig[] memory forwarders,
    address currentAdapter,
    address destinationAdapter
  ) internal pure returns (bool) {
    for (uint256 i = 0; i < forwarders.length; i++) {
      if (
        forwarders[i].currentChainBridgeAdapter == currentAdapter &&
        forwarders[i].destinationBridgeAdapter == destinationAdapter
      ) return true;
    }
    return false;
  }
}

contract EthereumReplaceLZTest is EthereumPayloadScript, BaseReplaceLZTest('ethereum', 26387076) {
  function _currentChainId() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function _setUpAdapters() internal override {
    _wormholeExecutorAdapters[ChainIds.ETHEREUM] = _deploy(
      _wormholeExecutorAdapterCode(ChainIds.ETHEREUM)
    );
    _gnosisPathCCIPAdapters[ChainIds.ETHEREUM] = _deploy(
      _gnosisPathCCIPAdapterCode(ChainIds.ETHEREUM)
    );
    _wormholeExecutorAdapters[ChainIds.POLYGON] = _predict(
      _wormholeExecutorAdapterCode(ChainIds.POLYGON)
    );
    _wormholeExecutorAdapters[ChainIds.AVALANCHE] = _predict(
      _wormholeExecutorAdapterCode(ChainIds.AVALANCHE)
    );
    _wormholeExecutorAdapters[ChainIds.BNB] = _predict(_wormholeExecutorAdapterCode(ChainIds.BNB));
    _wormholeExecutorAdapters[ChainIds.MONAD] = _predict(
      _wormholeExecutorAdapterCode(ChainIds.MONAD)
    );
    _gnosisPathCCIPAdapters[ChainIds.GNOSIS] = _predict(
      _gnosisPathCCIPAdapterCode(ChainIds.GNOSIS)
    );
  }

  function _buildPayload() internal override returns (address) {
    return _deployPayload(_getPayloadArgs(_getAddresses(ChainIds.ETHEREUM)));
  }

  function _wormholeExecutorAdapter(uint256 chainId) internal view override returns (address) {
    return _wormholeExecutorAdapters[chainId];
  }

  function _gnosisPathCCIPAdapter(uint256 chainId) internal view override returns (address) {
    return _gnosisPathCCIPAdapters[chainId];
  }

  function _receiverSwaps() internal view override returns (ReceiverSwap[] memory swaps) {
    swaps = new ReceiverSwap[](2);
    swaps[0] = ReceiverSwap(
      ChainIds.POLYGON,
      LZ_BRIDGE_ADAPTER,
      _wormholeExecutorAdapters[ChainIds.ETHEREUM]
    );
    swaps[1] = ReceiverSwap(
      ChainIds.AVALANCHE,
      LZ_BRIDGE_ADAPTER,
      _wormholeExecutorAdapters[ChainIds.ETHEREUM]
    );
  }

  function _forwarderSwaps() internal view override returns (ForwarderSwap[] memory swaps) {
    address wormhole = _wormholeExecutorAdapters[ChainIds.ETHEREUM];
    swaps = new ForwarderSwap[](5);
    swaps[0] = ForwarderSwap(
      ChainIds.POLYGON,
      LZ_BRIDGE_ADAPTER,
      wormhole,
      _wormholeExecutorAdapters[ChainIds.POLYGON]
    );
    swaps[1] = ForwarderSwap(
      ChainIds.AVALANCHE,
      LZ_BRIDGE_ADAPTER,
      wormhole,
      _wormholeExecutorAdapters[ChainIds.AVALANCHE]
    );
    swaps[2] = ForwarderSwap(
      ChainIds.BNB,
      LZ_BRIDGE_ADAPTER,
      wormhole,
      _wormholeExecutorAdapters[ChainIds.BNB]
    );
    swaps[3] = ForwarderSwap(
      ChainIds.MONAD,
      MONAD_LZ_BRIDGE_ADAPTER,
      wormhole,
      _wormholeExecutorAdapters[ChainIds.MONAD]
    );
    swaps[4] = ForwarderSwap(
      ChainIds.GNOSIS,
      LZ_BRIDGE_ADAPTER,
      _gnosisPathCCIPAdapters[ChainIds.ETHEREUM],
      _gnosisPathCCIPAdapters[ChainIds.GNOSIS]
    );
  }

  function _deliver(ReceiverSwap memory swap, bytes memory encodedTransaction) internal override {
    uint16 origin = swap.originChainId == ChainIds.POLYGON
      ? WORMHOLE_ID_POLYGON
      : WORMHOLE_ID_AVALANCHE;
    _deliverViaWormhole(swap, origin, encodedTransaction);
  }

  function test_celoPathUntouched() public {
    ICrossChainForwarder.ChainIdBridgeConfig[] memory before = _forwarders(ChainIds.CELO);
    uint256 bandwidthBefore = _bandwidth(ChainIds.CELO);
    assertTrue(_hasCurrentAdapter(before, LZ_BRIDGE_ADAPTER));

    executePayload(vm, _payload);

    ICrossChainForwarder.ChainIdBridgeConfig[] memory afterForwarders = _forwarders(ChainIds.CELO);
    assertEq(abi.encode(afterForwarders), abi.encode(before));
    assertEq(_bandwidth(ChainIds.CELO), bandwidthBefore);
  }
}

abstract contract BaseRemoteReplaceLZTest is BaseReplaceLZTest {
  function _replacedAdapter() internal view virtual returns (address);

  function _replacementAdapter() internal view virtual returns (address);

  function _receiverSwaps() internal view override returns (ReceiverSwap[] memory swaps) {
    swaps = new ReceiverSwap[](1);
    swaps[0] = ReceiverSwap(ChainIds.ETHEREUM, _replacedAdapter(), _replacementAdapter());
  }
}

abstract contract BaseRemoteWormholeReplaceLZTest is BaseRemoteReplaceLZTest {
  function _setUpAdapters() internal override {
    _wormholeExecutorAdapters[_currentChainId()] = _deploy(
      _wormholeExecutorAdapterCode(_currentChainId())
    );
    _wormholeExecutorAdapters[ChainIds.ETHEREUM] = _predict(
      _wormholeExecutorAdapterCode(ChainIds.ETHEREUM)
    );
  }

  function _replacementAdapter() internal view override returns (address) {
    return _wormholeExecutorAdapters[_currentChainId()];
  }

  function _deliver(ReceiverSwap memory swap, bytes memory encodedTransaction) internal override {
    _deliverViaWormhole(swap, WORMHOLE_ID_ETHEREUM, encodedTransaction);
  }
}

/// @dev chains that also forward back to Ethereum
abstract contract BaseReturnPathReplaceLZTest is BaseRemoteWormholeReplaceLZTest {
  function _forwarderSwaps() internal view override returns (ForwarderSwap[] memory swaps) {
    swaps = new ForwarderSwap[](1);
    swaps[0] = ForwarderSwap(
      ChainIds.ETHEREUM,
      _replacedAdapter(),
      _replacementAdapter(),
      _wormholeExecutorAdapters[ChainIds.ETHEREUM]
    );
  }
}

contract PolygonReplaceLZTest is PolygonPayloadScript, BaseReturnPathReplaceLZTest {
  constructor() BaseReplaceLZTest('polygon', 97092752) {}

  function _currentChainId() internal pure override returns (uint256) {
    return ChainIds.POLYGON;
  }

  function _replacedAdapter() internal view override returns (address) {
    return _getAddresses(ChainIds.POLYGON).lzAdapter;
  }

  function _buildPayload() internal override returns (address) {
    return _deployPayload(_getPayloadArgs(_getAddresses(ChainIds.POLYGON)));
  }

  function _wormholeExecutorAdapter(uint256 chainId) internal view override returns (address) {
    return _wormholeExecutorAdapters[chainId];
  }
}

contract AvalancheReplaceLZTest is AvalanchePayloadScript, BaseReturnPathReplaceLZTest {
  constructor() BaseReplaceLZTest('avalanche', 99968243) {}

  function _currentChainId() internal pure override returns (uint256) {
    return ChainIds.AVALANCHE;
  }

  function _replacedAdapter() internal view override returns (address) {
    return _getAddresses(ChainIds.AVALANCHE).lzAdapter;
  }

  function _buildPayload() internal override returns (address) {
    return _deployPayload(_getPayloadArgs(_getAddresses(ChainIds.AVALANCHE)));
  }

  function _wormholeExecutorAdapter(uint256 chainId) internal view override returns (address) {
    return _wormholeExecutorAdapters[chainId];
  }
}

contract BinanceReplaceLZTest is BinancePayloadScript, BaseRemoteWormholeReplaceLZTest {
  constructor() BaseReplaceLZTest('binance', 132844954) {}

  function _currentChainId() internal pure override returns (uint256) {
    return ChainIds.BNB;
  }

  function _replacedAdapter() internal view override returns (address) {
    return _getAddresses(ChainIds.BNB).lzAdapter;
  }

  function _buildPayload() internal override returns (address) {
    return _deployPayload(_getPayloadArgs(_getAddresses(ChainIds.BNB)));
  }

  function _wormholeExecutorAdapter(uint256 chainId) internal view override returns (address) {
    return _wormholeExecutorAdapters[chainId];
  }
}

/// @dev forge only forks Monad from a Monad EVM: `forge test --match-contract MonadReplaceLZTest --fork-url monad`
contract MonadReplaceLZTest is MonadPayloadScript, BaseRemoteWormholeReplaceLZTest {
  constructor() BaseReplaceLZTest('monad', 121136330) {}

  function _fork() internal override {
    try vm.createSelectFork(vm.rpcUrl(NETWORK), BLOCK_NUMBER) {} catch {
      vm.skip(true);
    }
  }

  /// @dev aave-helpers has no Monad payloads controller, so execute as it would
  function executePayload(Vm, address payload) internal override {
    address executor = IOwnable(_crossChainController).owner();
    vm.prank(IOwnable(executor).owner());
    IExecutor(executor).executeTransaction(payload, 0, 'execute()', '', true);
  }

  function _currentChainId() internal pure override returns (uint256) {
    return ChainIds.MONAD;
  }

  function _replacedAdapter() internal view override returns (address) {
    return _getAddresses(ChainIds.MONAD).lzAdapter;
  }

  function _buildPayload() internal override returns (address) {
    return _deployPayload(_getPayloadArgs(_getAddresses(ChainIds.MONAD)));
  }

  function _wormholeExecutorAdapter(uint256 chainId) internal view override returns (address) {
    return _wormholeExecutorAdapters[chainId];
  }
}

contract GnosisReplaceLZTest is GnosisPayloadScript, BaseRemoteReplaceLZTest {
  constructor() BaseReplaceLZTest('gnosis', 49213347) {}

  function _currentChainId() internal pure override returns (uint256) {
    return ChainIds.GNOSIS;
  }

  function _setUpAdapters() internal override {
    _gnosisPathCCIPAdapters[ChainIds.GNOSIS] = _deploy(_gnosisPathCCIPAdapterCode(ChainIds.GNOSIS));
  }

  function _replacedAdapter() internal view override returns (address) {
    return _getAddresses(ChainIds.GNOSIS).lzAdapter;
  }

  function _replacementAdapter() internal view override returns (address) {
    return _gnosisPathCCIPAdapters[ChainIds.GNOSIS];
  }

  function _buildPayload() internal override returns (address) {
    return _deployPayload(_getPayloadArgs(_getAddresses(ChainIds.GNOSIS)));
  }

  function _gnosisPathCCIPAdapter(uint256 chainId) internal view override returns (address) {
    return _gnosisPathCCIPAdapters[chainId];
  }

  function _deliver(ReceiverSwap memory swap, bytes memory encodedTransaction) internal override {
    _deliverViaCCIP(swap, CCIP_SELECTOR_ETHEREUM, encodedTransaction);
  }
}
