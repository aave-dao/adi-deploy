// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.22;

import 'forge-std/Test.sol';
import 'adi/access_control/GranularGuardianAccessControl.sol';
import {OwnableWithGuardian} from 'adi/old-oz/OwnableWithGuardian.sol';
import {IWithGuardian} from 'solidity-utils/contracts/access-control/interfaces/IWithGuardian.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GovernanceV3Polygon} from 'aave-address-book/GovernanceV3Polygon.sol';
import {GovernanceV3Avalanche} from 'aave-address-book/GovernanceV3Avalanche.sol';
import {GovernanceV3BNB} from 'aave-address-book/GovernanceV3BNB.sol';
import {GovernanceV3Gnosis} from 'aave-address-book/GovernanceV3Gnosis.sol';
import {GovernanceV3Metis} from 'aave-address-book/GovernanceV3Metis.sol';
import {GovernanceV3Optimism} from 'aave-address-book/GovernanceV3Optimism.sol';
import {GovernanceV3Arbitrum} from 'aave-address-book/GovernanceV3Arbitrum.sol';
import {GovernanceV3Base} from 'aave-address-book/GovernanceV3Base.sol';

abstract contract BaseGranularGuardianMigrationTest is Test {
  string internal NETWORK;
  uint256 internal BLOCK_NUMBER;
  constructor(string memory network, uint256 blockNumber) {
    NETWORK = network;
    BLOCK_NUMBER = blockNumber;
  }

  function CROSS_CHAIN_CONTROLLER() internal view virtual returns (address);

  function GRANULAR_GUARDIAN() internal view virtual returns (address);

  function AAVE_GOVERNANCE_GUARDIAN() internal view virtual returns (address);

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl(NETWORK), BLOCK_NUMBER);
  }

  function test_migrationToGranularGuardian() public {
    address ccc = CROSS_CHAIN_CONTROLLER();
    address granularGuardian = GRANULAR_GUARDIAN();
    address currentGuardian = OwnableWithGuardian(ccc).guardian();

    GranularGuardianAccessControl gg = GranularGuardianAccessControl(granularGuardian);

    // Retry role should be the current ccc guardian (before migration)
    assertEq(
      gg.getRoleMember(gg.RETRY_ROLE(), 0),
      currentGuardian,
      'Retry guardian should be current ccc guardian'
    );

    // Rescue (solve emergency) role should be the aave governance guardian
    assertEq(
      gg.getRoleMember(gg.SOLVE_EMERGENCY_ROLE(), 0),
      AAVE_GOVERNANCE_GUARDIAN(),
      'Rescue guardian should be aave governance guardian'
    );

    // Prank current ccc guardian and change to granular guardian
    vm.prank(currentGuardian);
    OwnableWithGuardian(ccc).updateGuardian(granularGuardian);

    // Verify ccc now has the correct granular guardian
    assertEq(
      OwnableWithGuardian(ccc).guardian(),
      granularGuardian,
      'CCC guardian should be granular guardian after migration'
    );
  }

  function test_migrationViaCalldata() public {
    address ccc = CROSS_CHAIN_CONTROLLER();
    address granularGuardian = GRANULAR_GUARDIAN();
    address currentGuardian = OwnableWithGuardian(ccc).guardian();

    // Build the exact calldata the script generates
    bytes memory callData = abi.encodeWithSelector(
      IWithGuardian.updateGuardian.selector,
      granularGuardian
    );

    // Execute the calldata as the current guardian (Safe)
    vm.prank(currentGuardian);
    (bool success, ) = ccc.call(callData);
    assertTrue(success, 'Calldata execution should succeed');

    // Verify guardian was updated
    assertEq(
      OwnableWithGuardian(ccc).guardian(),
      granularGuardian,
      'CCC guardian should be granular guardian after calldata execution'
    );

    // Verify granular guardian roles are intact after migration
    GranularGuardianAccessControl gg = GranularGuardianAccessControl(granularGuardian);
    assertEq(
      gg.getRoleMember(gg.RETRY_ROLE(), 0),
      currentGuardian,
      'Retry role should still be the original guardian'
    );
    assertEq(
      gg.getRoleMember(gg.SOLVE_EMERGENCY_ROLE(), 0),
      AAVE_GOVERNANCE_GUARDIAN(),
      'Solve emergency role should still be aave governance guardian'
    );
  }

  function test_migrationCalldataRevertsIfNotGuardian() public {
    address ccc = CROSS_CHAIN_CONTROLLER();
    address granularGuardian = GRANULAR_GUARDIAN();

    bytes memory callData = abi.encodeWithSelector(
      IWithGuardian.updateGuardian.selector,
      granularGuardian
    );

    // Should revert when called by a random address
    address randomCaller = address(0xdead);
    vm.prank(randomCaller);
    (bool success, ) = ccc.call(callData);
    assertFalse(success, 'Calldata execution should revert for non-guardian');

    // Guardian should remain unchanged
    assertNotEq(
      OwnableWithGuardian(ccc).guardian(),
      granularGuardian,
      'Guardian should not have changed'
    );
  }
}

contract ArbitrumGranularGuardianMigrationTest is BaseGranularGuardianMigrationTest('arbitrum', 438922374) {
  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Arbitrum.CROSS_CHAIN_CONTROLLER;
  }

  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Arbitrum.GRANULAR_GUARDIAN;
  }

  function AAVE_GOVERNANCE_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Arbitrum.GOVERNANCE_GUARDIAN;
  }
}

contract AvalancheGranularGuardianMigrationTest is BaseGranularGuardianMigrationTest('avalanche', 79703934) {
  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Avalanche.CROSS_CHAIN_CONTROLLER;
  }

  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Avalanche.GRANULAR_GUARDIAN;
  }

  function AAVE_GOVERNANCE_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Avalanche.GOVERNANCE_GUARDIAN;
  }
}

contract BaseNetworkGranularGuardianMigrationTest is BaseGranularGuardianMigrationTest('base', 43003513) {
  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Base.CROSS_CHAIN_CONTROLLER;
  }

  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Base.GRANULAR_GUARDIAN;
  }

  function AAVE_GOVERNANCE_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Base.GOVERNANCE_GUARDIAN;
  }
}

contract BinanceGranularGuardianMigrationTest is BaseGranularGuardianMigrationTest('binance', 85000573) {
  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3BNB.CROSS_CHAIN_CONTROLLER;
  }

  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3BNB.GRANULAR_GUARDIAN;
  }

  function AAVE_GOVERNANCE_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3BNB.GOVERNANCE_GUARDIAN;
  }
}

contract EthereumGranularGuardianMigrationTest is BaseGranularGuardianMigrationTest('ethereum', 24598106) {
  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER;
  }

  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Ethereum.GRANULAR_GUARDIAN;
  }

  function AAVE_GOVERNANCE_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Ethereum.GOVERNANCE_GUARDIAN;
  }
}

contract GnosisGranularGuardianMigrationTest is BaseGranularGuardianMigrationTest('gnosis', 45011256) {
  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Gnosis.CROSS_CHAIN_CONTROLLER;
  }

  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Gnosis.GRANULAR_GUARDIAN;
  }

  function AAVE_GOVERNANCE_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Gnosis.GOVERNANCE_GUARDIAN;
  }
}

contract MetisGranularGuardianMigrationTest is BaseGranularGuardianMigrationTest('metis', 22297497) {
  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Metis.CROSS_CHAIN_CONTROLLER;
  }

  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Metis.GRANULAR_GUARDIAN;
  }

  function AAVE_GOVERNANCE_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Metis.GOVERNANCE_GUARDIAN;
  }
}

contract OptimismGranularGuardianMigrationTest is BaseGranularGuardianMigrationTest('optimism', 148598798) {
  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Optimism.CROSS_CHAIN_CONTROLLER;
  }

  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Optimism.GRANULAR_GUARDIAN;
  }

  function AAVE_GOVERNANCE_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Optimism.GOVERNANCE_GUARDIAN;
  }
}

contract PolygonGranularGuardianMigrationTest is BaseGranularGuardianMigrationTest('polygon', 83838171) {
  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER;
  }

  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Polygon.GRANULAR_GUARDIAN;
  }

  function AAVE_GOVERNANCE_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Polygon.GOVERNANCE_GUARDIAN;
  }
}
