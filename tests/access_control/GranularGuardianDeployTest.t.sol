// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'adi/access_control/GranularGuardianAccessControl.sol';
import 'adi-tests/BaseTest.sol';
import {OwnableWithGuardian} from 'adi/old-oz/OwnableWithGuardian.sol';
import {TestUtils} from 'adi-tests/utils/TestUtils.sol';
import {Ethereum, Polygon, Avalanche, Binance, Gnosis, Metis, Scroll, Optimism, Arbitrum, Base, Linea} from '../../scripts/access_control/network_scripts/GranularGuardianNetworkDeploys.s.sol';
import {IAccessControl} from 'openzeppelin-contracts/contracts/access/IAccessControl.sol';

abstract contract BaseGGTest is BaseTest {
  bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
  GranularGuardianAccessControl public control;

  string internal NETWORK;
  uint256 internal immutable BLOCK_NUMBER;

  constructor(string memory network, uint256 blockNumber) {
    NETWORK = network;
    BLOCK_NUMBER = blockNumber;
  }

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl(NETWORK), BLOCK_NUMBER);
    address ccc = CROSS_CHAIN_CONTROLLER();
    control = _deployGG();
    address guardian = OwnableWithGuardian(ccc).guardian();

    hoax(guardian);
    OwnableWithGuardian(ccc).updateGuardian(address(control));
  }

  function CROSS_CHAIN_CONTROLLER() internal view virtual returns (address);

  function _deployGG() internal virtual returns (GranularGuardianAccessControl);

  function _getDefaultAdmin() internal view virtual returns (address);

  function _getRetryGuardian() internal view virtual returns (address);

  function _getSolveEmergencyGuardian() internal view virtual returns (address);

  function _getDestinationChainId() internal view virtual returns (uint256) {
    return 0;
  }

  function test_initialization() public {
    assertEq(control.CROSS_CHAIN_CONTROLLER(), CROSS_CHAIN_CONTROLLER());
    assertEq(control.hasRole(DEFAULT_ADMIN_ROLE, _getDefaultAdmin()), true);
    assertEq(control.getRoleAdmin(control.RETRY_ROLE()), DEFAULT_ADMIN_ROLE);
    assertEq(control.getRoleAdmin(control.SOLVE_EMERGENCY_ROLE()), DEFAULT_ADMIN_ROLE);
    assertEq(control.getRoleMemberCount(control.RETRY_ROLE()), 1);
    assertEq(control.getRoleMemberCount(control.SOLVE_EMERGENCY_ROLE()), 1);
    assertEq(control.getRoleMember(control.RETRY_ROLE(), 0), _getRetryGuardian());
    assertEq(
      control.getRoleMember(control.SOLVE_EMERGENCY_ROLE(), 0),
      _getSolveEmergencyGuardian()
    );
  }

  function test_updateGuardian(address newGuardian) public {
    _filterAddress(newGuardian);
    vm.startPrank(_getDefaultAdmin());
    control.updateGuardian(newGuardian);
    assertEq(IWithGuardian(CROSS_CHAIN_CONTROLLER()).guardian(), newGuardian);
    vm.stopPrank();
  }

  function test_updateGuardianWhenWrongCaller(address newGuardian, address caller) public {
    vm.assume(caller != _getDefaultAdmin());
    hoax(caller);
    vm.expectRevert(
      abi.encodeWithSelector(
        IAccessControl.AccessControlUnauthorizedAccount.selector,
        caller,
        0x0000000000000000000000000000000000000000000000000000000000000000
      )
    );
    control.updateGuardian(newGuardian);
  }
}

abstract contract BaseCCCWithEmergency is BaseGGTest {
  constructor(string memory network, uint256 blockNumber) BaseGGTest(network, blockNumber) {}

  function test_solveEmergencyDeprecated()
    public
    generateEmergencyState(CROSS_CHAIN_CONTROLLER())
    validateEmergencySolved(CROSS_CHAIN_CONTROLLER())
  {
    vm.startPrank(_getSolveEmergencyGuardian());
    control.solveEmergencyDeprecated(
      new ICrossChainReceiver.ConfirmationInput[](0),
      new ICrossChainReceiver.ValidityTimestampInput[](0),
      new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0),
      new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0),
      new address[](0),
      new address[](0),
      new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](0),
      new ICrossChainForwarder.BridgeAdapterToDisable[](0)
    );
    vm.stopPrank();
  }

  function test_solveEmergencyDeprecatedWhenWrongCaller(address caller) public {
    vm.assume(caller != _getSolveEmergencyGuardian());
    hoax(caller);
    vm.expectRevert(
      abi.encodeWithSelector(
        IAccessControl.AccessControlUnauthorizedAccount.selector,
        caller,
        0xf4cdc679c22cbf47d6de8e836ce79ffdae51f38408dcde3f0645de7634fa607d
      )
    );
    control.solveEmergencyDeprecated(
      new ICrossChainReceiver.ConfirmationInput[](0),
      new ICrossChainReceiver.ValidityTimestampInput[](0),
      new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0),
      new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0),
      new address[](0),
      new address[](0),
      new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](0),
      new ICrossChainForwarder.BridgeAdapterToDisable[](0)
    );
  }
}

abstract contract BaseCCForwarder is BaseGGTest {
  constructor(string memory network, uint256 blockNumber) BaseGGTest(network, blockNumber) {}

  function test_retryTx(
    address destination,
    uint256 gasLimit
  )
    public
    generateRetryTxState(
      _getDefaultAdmin(),
      CROSS_CHAIN_CONTROLLER(),
      _getDestinationChainId(),
      destination,
      gasLimit
    )
  {
    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(
      TestParams({
        destination: destination,
        origin: address(this),
        originChainId: block.chainid,
        destinationChainId: _getDestinationChainId(),
        envelopeNonce: ICrossChainForwarder(CROSS_CHAIN_CONTROLLER()).getCurrentTransactionNonce() -
          1,
        transactionNonce: ICrossChainForwarder(CROSS_CHAIN_CONTROLLER())
          .getCurrentTransactionNonce() - 1
      })
    );

    ICrossChainForwarder.ChainIdBridgeConfig[] memory bridgeAdaptersByChain = ICrossChainForwarder(
      CROSS_CHAIN_CONTROLLER()
    ).getForwarderBridgeAdaptersByChain(_getDestinationChainId());
    address[] memory bridgeAdaptersToRetry = new address[](1);
    if (bridgeAdaptersByChain.length > 1) {
      bridgeAdaptersToRetry[0] = bridgeAdaptersByChain[1].currentChainBridgeAdapter;
    } else {
      bridgeAdaptersToRetry[0] = bridgeAdaptersByChain[0].currentChainBridgeAdapter;
    }

    vm.startPrank(_getRetryGuardian());
    control.retryTransaction(extendedTx.transactionEncoded, gasLimit, bridgeAdaptersToRetry);
    vm.stopPrank();
  }

  function test_retryTxWhenWrongCaller(uint256 gasLimit, address caller) public {
    address[] memory bridgeAdaptersToRetry = new address[](0);
    vm.assume(caller != _getRetryGuardian());

    hoax(caller);
    vm.expectRevert(
      abi.encodeWithSelector(
        IAccessControl.AccessControlUnauthorizedAccount.selector,
        caller,
        0xc448b9502bbdf9850cc39823b6ea40cfe96d3ac63008e89edd2b8e98c6cc0af3
      )
    );

    control.retryTransaction(abi.encode('will not get used'), gasLimit, bridgeAdaptersToRetry);
  }

  function test_retryEnvelope(
    address destination,
    uint256 gasLimit
  )
    public
    generateRetryTxState(
      _getDefaultAdmin(),
      CROSS_CHAIN_CONTROLLER(),
      _getDestinationChainId(),
      destination,
      gasLimit
    )
  {
    uint256 envNonce = ICrossChainForwarder(CROSS_CHAIN_CONTROLLER()).getCurrentEnvelopeNonce() - 1;

    ExtendedTransaction memory extendedTx = _generateExtendedTransaction(
      TestParams({
        destination: destination,
        origin: address(this),
        originChainId: block.chainid,
        destinationChainId: _getDestinationChainId(),
        envelopeNonce: envNonce,
        transactionNonce: ICrossChainForwarder(CROSS_CHAIN_CONTROLLER())
          .getCurrentTransactionNonce() - 1
      })
    );

    vm.startPrank(_getRetryGuardian());
    bytes32 newTxId = control.retryEnvelope(extendedTx.envelope, gasLimit);

    ExtendedTransaction memory extendedTxAfter = _generateExtendedTransaction(
      TestParams({
        destination: destination,
        origin: address(this),
        originChainId: block.chainid,
        destinationChainId: _getDestinationChainId(),
        envelopeNonce: envNonce,
        transactionNonce: ICrossChainForwarder(CROSS_CHAIN_CONTROLLER())
          .getCurrentTransactionNonce() - 1
      })
    );

    assertEq(extendedTxAfter.transactionId, newTxId);
    vm.stopPrank();
  }

  function test_retryEnvelopeWhenWrongCaller(uint256 gasLimit, address caller) public {
    vm.assume(caller != _getRetryGuardian());

    Envelope memory envelope;

    hoax(caller);
    vm.expectRevert(
      abi.encodeWithSelector(
        IAccessControl.AccessControlUnauthorizedAccount.selector,
        caller,
        0xc448b9502bbdf9850cc39823b6ea40cfe96d3ac63008e89edd2b8e98c6cc0af3
      )
    );
    control.retryEnvelope(envelope, gasLimit);
  }
}

abstract contract BaseCCForwarderWithEmergency is BaseCCForwarder {
  constructor(string memory network, uint256 blockNumber) BaseCCForwarder(network, blockNumber) {}

  function test_solveEmergencyDeprecated()
    public
    generateEmergencyState(CROSS_CHAIN_CONTROLLER())
    validateEmergencySolved(CROSS_CHAIN_CONTROLLER())
  {
    vm.startPrank(_getSolveEmergencyGuardian());
    control.solveEmergencyDeprecated(
      new ICrossChainReceiver.ConfirmationInput[](0),
      new ICrossChainReceiver.ValidityTimestampInput[](0),
      new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0),
      new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0),
      new address[](0),
      new address[](0),
      new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](0),
      new ICrossChainForwarder.BridgeAdapterToDisable[](0)
    );
    vm.stopPrank();
  }

  function test_solveEmergencyWhenWrongCallerDeprecated(address caller) public {
    vm.assume(caller != _getSolveEmergencyGuardian());
    hoax(caller);
    vm.expectRevert(
      abi.encodeWithSelector(
        IAccessControl.AccessControlUnauthorizedAccount.selector,
        caller,
        0xf4cdc679c22cbf47d6de8e836ce79ffdae51f38408dcde3f0645de7634fa607d
      )
    );
    control.solveEmergencyDeprecated(
      new ICrossChainReceiver.ConfirmationInput[](0),
      new ICrossChainReceiver.ValidityTimestampInput[](0),
      new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0),
      new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0),
      new address[](0),
      new address[](0),
      new ICrossChainForwarder.ForwarderBridgeAdapterConfigInput[](0),
      new ICrossChainForwarder.BridgeAdapterToDisable[](0)
    );
  }
}

contract EthereumGGTest is Ethereum, BaseCCForwarder('ethereum', 20092947) {
  function CROSS_CHAIN_CONTROLLER() internal view override returns (address) {
    return _getAddresses(TRANSACTION_NETWORK()).crossChainController;
  }

  function _deployGG() internal override returns (GranularGuardianAccessControl) {
    return GranularGuardianAccessControl(_deployGranularGuardian(CROSS_CHAIN_CONTROLLER()));
  }

  function _getDestinationChainId() internal pure override returns (uint256) {
    return ChainIds.POLYGON;
  }

  function _getDefaultAdmin() internal pure override returns (address) {
    return DEFAULT_ADMIN();
  }

  function _getRetryGuardian() internal pure override returns (address) {
    return RETRY_GUARDIAN();
  }

  function _getSolveEmergencyGuardian() internal pure override returns (address) {
    return SOLVE_EMERGENCY_GUARDIAN();
  }
}

contract PolygonGGTest is Polygon, BaseCCForwarderWithEmergency('polygon', 58168704) {
  function CROSS_CHAIN_CONTROLLER() internal view override returns (address) {
    return _getAddresses(TRANSACTION_NETWORK()).crossChainController;
  }

  function _deployGG() internal override returns (GranularGuardianAccessControl) {
    return GranularGuardianAccessControl(_deployGranularGuardian(CROSS_CHAIN_CONTROLLER()));
  }

  function _getDestinationChainId() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function _getDefaultAdmin() internal pure override returns (address) {
    return DEFAULT_ADMIN();
  }

  function _getRetryGuardian() internal pure override returns (address) {
    return RETRY_GUARDIAN();
  }

  function _getSolveEmergencyGuardian() internal pure override returns (address) {
    return SOLVE_EMERGENCY_GUARDIAN();
  }
}

contract AvalancheGGTest is Avalanche, BaseCCForwarderWithEmergency('avalanche', 46727153) {
  function CROSS_CHAIN_CONTROLLER() internal view override returns (address) {
    return _getAddresses(TRANSACTION_NETWORK()).crossChainController;
  }

  function _deployGG() internal override returns (GranularGuardianAccessControl) {
    return GranularGuardianAccessControl(_deployGranularGuardian(CROSS_CHAIN_CONTROLLER()));
  }

  function _getDestinationChainId() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function _getDefaultAdmin() internal pure override returns (address) {
    return DEFAULT_ADMIN();
  }

  function _getRetryGuardian() internal pure override returns (address) {
    return RETRY_GUARDIAN();
  }

  function _getSolveEmergencyGuardian() internal pure override returns (address) {
    return SOLVE_EMERGENCY_GUARDIAN();
  }
}

contract BinanceGGTest is Binance, BaseCCCWithEmergency('binance', 40353415) {
  function CROSS_CHAIN_CONTROLLER() internal view override returns (address) {
    return _getAddresses(TRANSACTION_NETWORK()).crossChainController;
  }

  function _deployGG() internal override returns (GranularGuardianAccessControl) {
    return GranularGuardianAccessControl(_deployGranularGuardian(CROSS_CHAIN_CONTROLLER()));
  }

  function _getDefaultAdmin() internal pure override returns (address) {
    return DEFAULT_ADMIN();
  }

  function _getRetryGuardian() internal pure override returns (address) {
    return RETRY_GUARDIAN();
  }

  function _getSolveEmergencyGuardian() internal pure override returns (address) {
    return SOLVE_EMERGENCY_GUARDIAN();
  }
}

contract GnosisGGTest is Gnosis, BaseCCCWithEmergency('gnosis', 34896209) {
  function CROSS_CHAIN_CONTROLLER() internal view override returns (address) {
    return _getAddresses(TRANSACTION_NETWORK()).crossChainController;
  }

  function _deployGG() internal override returns (GranularGuardianAccessControl) {
    return GranularGuardianAccessControl(_deployGranularGuardian(CROSS_CHAIN_CONTROLLER()));
  }

  function _getDefaultAdmin() internal pure override returns (address) {
    return DEFAULT_ADMIN();
  }

  function _getRetryGuardian() internal pure override returns (address) {
    return RETRY_GUARDIAN();
  }

  function _getSolveEmergencyGuardian() internal pure override returns (address) {
    return SOLVE_EMERGENCY_GUARDIAN();
  }
}

contract MetisGGTest is Metis, BaseGGTest('metis', 17364742) {
  function CROSS_CHAIN_CONTROLLER() internal view override returns (address) {
    return _getAddresses(TRANSACTION_NETWORK()).crossChainController;
  }

  function _deployGG() internal override returns (GranularGuardianAccessControl) {
    return GranularGuardianAccessControl(_deployGranularGuardian(CROSS_CHAIN_CONTROLLER()));
  }

  function _getDefaultAdmin() internal pure override returns (address) {
    return DEFAULT_ADMIN();
  }

  function _getRetryGuardian() internal pure override returns (address) {
    return RETRY_GUARDIAN();
  }

  function _getSolveEmergencyGuardian() internal pure override returns (address) {
    return SOLVE_EMERGENCY_GUARDIAN();
  }
}

contract ScrollGGTest is Scroll, BaseGGTest('scroll', 7306114) {
  function CROSS_CHAIN_CONTROLLER() internal view override returns (address) {
    return _getAddresses(TRANSACTION_NETWORK()).crossChainController;
  }

  function _deployGG() internal override returns (GranularGuardianAccessControl) {
    return GranularGuardianAccessControl(_deployGranularGuardian(CROSS_CHAIN_CONTROLLER()));
  }

  function _getDefaultAdmin() internal pure override returns (address) {
    return DEFAULT_ADMIN();
  }

  function _getRetryGuardian() internal pure override returns (address) {
    return RETRY_GUARDIAN();
  }

  function _getSolveEmergencyGuardian() internal pure override returns (address) {
    return SOLVE_EMERGENCY_GUARDIAN();
  }
}

contract OptimismGGTest is Optimism, BaseGGTest('optimism', 121491625) {
  function CROSS_CHAIN_CONTROLLER() internal view override returns (address) {
    return _getAddresses(TRANSACTION_NETWORK()).crossChainController;
  }

  function _deployGG() internal override returns (GranularGuardianAccessControl) {
    return GranularGuardianAccessControl(_deployGranularGuardian(CROSS_CHAIN_CONTROLLER()));
  }

  function _getDefaultAdmin() internal pure override returns (address) {
    return DEFAULT_ADMIN();
  }

  function _getRetryGuardian() internal pure override returns (address) {
    return RETRY_GUARDIAN();
  }

  function _getSolveEmergencyGuardian() internal pure override returns (address) {
    return SOLVE_EMERGENCY_GUARDIAN();
  }
}

contract ArbitrumGGTest is Arbitrum, BaseGGTest('arbitrum', 222622842) {
  function CROSS_CHAIN_CONTROLLER() internal view override returns (address) {
    return _getAddresses(TRANSACTION_NETWORK()).crossChainController;
  }

  function _deployGG() internal override returns (GranularGuardianAccessControl) {
    return GranularGuardianAccessControl(_deployGranularGuardian(CROSS_CHAIN_CONTROLLER()));
  }

  function _getDefaultAdmin() internal pure override returns (address) {
    return DEFAULT_ADMIN();
  }

  function _getRetryGuardian() internal pure override returns (address) {
    return RETRY_GUARDIAN();
  }

  function _getSolveEmergencyGuardian() internal pure override returns (address) {
    return SOLVE_EMERGENCY_GUARDIAN();
  }
}

contract CBaseGGTest is Base, BaseGGTest('base', 15896446) {
  function CROSS_CHAIN_CONTROLLER() internal view override returns (address) {
    return _getAddresses(TRANSACTION_NETWORK()).crossChainController;
  }

  function _deployGG() internal override returns (GranularGuardianAccessControl) {
    return GranularGuardianAccessControl(_deployGranularGuardian(CROSS_CHAIN_CONTROLLER()));
  }

  function _getDefaultAdmin() internal pure override returns (address) {
    return DEFAULT_ADMIN();
  }

  function _getRetryGuardian() internal pure override returns (address) {
    return RETRY_GUARDIAN();
  }

  function _getSolveEmergencyGuardian() internal pure override returns (address) {
    return SOLVE_EMERGENCY_GUARDIAN();
  }
}

contract LineaGGTest is Linea, BaseGGTest('linea', 13223742) {
  function CROSS_CHAIN_CONTROLLER() internal view override returns (address) {
    return _getAddresses(TRANSACTION_NETWORK()).crossChainController;
  }

  function _deployGG() internal override returns (GranularGuardianAccessControl) {
    return GranularGuardianAccessControl(_deployGranularGuardian(CROSS_CHAIN_CONTROLLER()));
  }

  function _getDefaultAdmin() internal pure override returns (address) {
    return DEFAULT_ADMIN();
  }

  function _getRetryGuardian() internal pure override returns (address) {
    return RETRY_GUARDIAN();
  }

  function _getSolveEmergencyGuardian() internal pure override returns (address) {
    return SOLVE_EMERGENCY_GUARDIAN();
  }
}
