// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';
import {GranularGuardianAccessControl} from 'adi/access_control/GranularGuardianAccessControl.sol';
import {ADITestBase} from '../adi/ADITestBase.sol';
import {
  GGRetryRoleMigrationArgs,
  RetryRoleMigrationPayload
} from '../../src/gg_payloads/RetryRoleMigrationPayload.sol';
import {
  Arbitrum,
  Avalanche,
  Base,
  Binance,
  Bob,
  Celo,
  Ethereum,
  Gnosis,
  Ink,
  Linea,
  Mantle,
  Megaeth,
  Optimism,
  Plasma,
  Polygon,
  Scroll,
  Sonic,
  Xlayer
} from '../../scripts/payloads/gg/GG_retry_role_migration.s.sol';
import {GovernanceV3Arbitrum} from 'aave-address-book/GovernanceV3Arbitrum.sol';
import {GovernanceV3Avalanche} from 'aave-address-book/GovernanceV3Avalanche.sol';
import {GovernanceV3Base} from 'aave-address-book/GovernanceV3Base.sol';
import {GovernanceV3BNB} from 'aave-address-book/GovernanceV3BNB.sol';
import {GovernanceV3Bob} from 'aave-address-book/GovernanceV3Bob.sol';
import {GovernanceV3Celo} from 'aave-address-book/GovernanceV3Celo.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GovernanceV3Gnosis} from 'aave-address-book/GovernanceV3Gnosis.sol';
import {GovernanceV3Ink} from 'aave-address-book/GovernanceV3Ink.sol';
import {GovernanceV3Linea} from 'aave-address-book/GovernanceV3Linea.sol';
import {GovernanceV3Mantle} from 'aave-address-book/GovernanceV3Mantle.sol';
import {GovernanceV3MegaEth} from 'aave-address-book/GovernanceV3MegaEth.sol';
import {GovernanceV3Optimism} from 'aave-address-book/GovernanceV3Optimism.sol';
import {GovernanceV3Plasma} from 'aave-address-book/GovernanceV3Plasma.sol';
import {GovernanceV3Polygon} from 'aave-address-book/GovernanceV3Polygon.sol';
import {GovernanceV3Scroll} from 'aave-address-book/GovernanceV3Scroll.sol';
import {GovernanceV3Sonic} from 'aave-address-book/GovernanceV3Sonic.sol';
import {GovernanceV3XLayer} from 'aave-address-book/GovernanceV3XLayer.sol';

abstract contract BaseGGRetryRoleMigrationTest is ADITestBase {
  address internal _payload;
  string internal NETWORK;
  uint256 internal immutable BLOCK_NUMBER;
  address internal _granularGuardian;
  address internal _newRetryGuardian;

  function CURRENT_RETRY_GUARDIAN() internal view virtual returns (address);
  function CROSS_CHAIN_CONTROLLER() internal view virtual returns (address);

  function _getGranularGuardian() internal view virtual returns (address);
  function _getNewRetryGuardian() internal view virtual returns (address);
  function _getDeployedPayload() internal virtual returns (address);

  function _getPayload() internal virtual returns (address);

  constructor(string memory network, uint256 blockNumber) {
    NETWORK = network;
    BLOCK_NUMBER = blockNumber;
  }

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl(NETWORK), BLOCK_NUMBER);

    _payload = _getPayload();
    _granularGuardian = _getGranularGuardian();
    _newRetryGuardian = _getNewRetryGuardian();
  }

  function test_defaultTest() public {
    defaultTest(
      string.concat('gg_retry_role_migration', NETWORK),
      CROSS_CHAIN_CONTROLLER(),
      address(_payload),
      false,
      vm
    );
  }

  function test_samePayloadAddress() public {
    RetryRoleMigrationPayload deployedPayload = RetryRoleMigrationPayload(_getDeployedPayload());
    RetryRoleMigrationPayload predictedPayload = RetryRoleMigrationPayload(_getPayload());

    assertEq(predictedPayload.GRANULAR_GUARDIAN(), deployedPayload.GRANULAR_GUARDIAN());
    assertEq(predictedPayload.NEW_RETRY_GUARDIAN(), deployedPayload.NEW_RETRY_GUARDIAN());
    assertEq(address(predictedPayload), address(deployedPayload));
  }

  function test_migrationToNewRetryGuardian() public {
    address currentRetryGuardian = CURRENT_RETRY_GUARDIAN();

    GranularGuardianAccessControl gg = GranularGuardianAccessControl(_granularGuardian);

    assertEq(gg.getRoleMember(gg.RETRY_ROLE(), 0), currentRetryGuardian);

    executePayload(vm, address(_payload));

    assertEq(gg.getRoleMember(gg.RETRY_ROLE(), 0), _newRetryGuardian);
  }
}

// TODO: add block number
contract ArbitrumTest is Arbitrum, BaseGGRetryRoleMigrationTest('arbitrum', 222622842) {
  function _getGranularGuardian() internal pure override returns (address) {
    return GovernanceV3Arbitrum.GRANULAR_GUARDIAN;
  }

  function CURRENT_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x1Fcd437D8a9a6ea68da858b78b6cf10E8E0bF959; // BGD guardian
  }

  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Arbitrum.CROSS_CHAIN_CONTROLLER;
  }

  function _getDeployedPayload() internal pure override returns (address) {
    return address(0); // TODO: add deployed payload address
  }

  function _getPayload() internal override returns (address) {
    GGRetryRoleMigrationArgs memory args = GGRetryRoleMigrationArgs({
      granularGuardian: GRANULAR_GUARDIAN(),
      newRetryGuardian: NEW_RETRY_GUARDIAN()
    });
    return _deployPayload(args);
  }

  function _getNewRetryGuardian() internal pure override returns (address) {
    return NEW_RETRY_GUARDIAN();
  } 
}

// TODO: add block number
contract AvalancheTest is Avalanche, BaseGGRetryRoleMigrationTest('avalanche', 46727153) {
  function _getGranularGuardian() internal pure override returns (address) {
    return GovernanceV3Avalanche.GRANULAR_GUARDIAN;
  }

  function CURRENT_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x3DBA1c4094BC0eE4772A05180B7E0c2F1cFD9c36; // BGD guardian
  }

  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Avalanche.CROSS_CHAIN_CONTROLLER;
  }

  function _getDeployedPayload() internal pure override returns (address) {
    return address(0); // TODO: add deployed payload address
  }

  function _getPayload() internal override returns (address) {
    GGRetryRoleMigrationArgs memory args = GGRetryRoleMigrationArgs({
      granularGuardian: GRANULAR_GUARDIAN(),
      newRetryGuardian: NEW_RETRY_GUARDIAN()
    });
    return _deployPayload(args);
  }

  function _getNewRetryGuardian() internal pure override returns (address) {
    return NEW_RETRY_GUARDIAN();
  }
}

// TODO: add block number
contract BaseTest is Base, BaseGGRetryRoleMigrationTest('base', 43003513) {
  function _getGranularGuardian() internal pure override returns (address) {
    return GovernanceV3Base.GRANULAR_GUARDIAN;
  }

  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Base.CROSS_CHAIN_CONTROLLER;
  }

  function _getDeployedPayload() internal pure override returns (address) {
    return address(0); // TODO: add deployed payload address
  }

  function _getPayload() internal override returns (address) {
    GGRetryRoleMigrationArgs memory args = GGRetryRoleMigrationArgs({
      granularGuardian: GRANULAR_GUARDIAN(),
      newRetryGuardian: NEW_RETRY_GUARDIAN()
    });
    return _deployPayload(args);
  }

  function CURRENT_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x7FDA7C3528ad8f05e62148a700D456898b55f8d2; // BGD guardian
  }

  function _getNewRetryGuardian() internal pure override returns (address) {
    return NEW_RETRY_GUARDIAN();
  }
}

// TODO: add block number
contract BinanceTest is Binance, BaseGGRetryRoleMigrationTest('binance', 40353415) {
  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3BNB.CROSS_CHAIN_CONTROLLER;
  }

  function _getGranularGuardian() internal pure override returns (address) {
    return GovernanceV3BNB.GRANULAR_GUARDIAN;
  }

  function CURRENT_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0xE8C5ab722d0b1B7316Cc4034f2BE91A5B1d29964; // BGD guardian
  }
  function _getDeployedPayload() internal pure override returns (address) {
    return address(0); // TODO: add deployed payload address
  }

  function _getPayload() internal override returns (address) {
    GGRetryRoleMigrationArgs memory args = GGRetryRoleMigrationArgs({
      granularGuardian: GRANULAR_GUARDIAN(),
      newRetryGuardian: NEW_RETRY_GUARDIAN()
    });
    return _deployPayload(args);
  }

  function _getNewRetryGuardian() internal pure override returns (address) {
    return NEW_RETRY_GUARDIAN();
  }
}

// TODO: add block number
contract BobTest is Bob, BaseGGRetryRoleMigrationTest('bob', 10000000) {
  function _getGranularGuardian() internal pure override returns (address) {
    return GovernanceV3Bob.GRANULAR_GUARDIAN;
  }

  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Bob.CROSS_CHAIN_CONTROLLER;
  }

  function _getDeployedPayload() internal pure override returns (address) {
    return address(0); // TODO: add deployed payload address
  }

  function _getPayload() internal override returns (address) {
    GGRetryRoleMigrationArgs memory args = GGRetryRoleMigrationArgs({
      granularGuardian: GRANULAR_GUARDIAN(),
      newRetryGuardian: NEW_RETRY_GUARDIAN()
    });
    return _deployPayload(args);
  }

  function CURRENT_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0xdc62E0e65b2251Dc66404ca717FD32dcC365Be3A; // BGD guardian
  }

  function _getNewRetryGuardian() internal pure override returns (address) {
    return NEW_RETRY_GUARDIAN();
  }
}

// TODO: add block number
contract CeloTest is Celo, BaseGGRetryRoleMigrationTest('celo', 10000000) {
  function _getGranularGuardian() internal pure override returns (address) {
    return GovernanceV3Celo.GRANULAR_GUARDIAN;
  }

  function CURRENT_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0xfD3a6E65e470a7D7D730FFD5D36a9354E8F9F4Ea; // BGD guardian
  }

  function _getDeployedPayload() internal pure override returns (address) {
    return address(0); // TODO: add deployed payload address
  }

  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Celo.CROSS_CHAIN_CONTROLLER;
  }

  function _getPayload() internal override returns (address) {
    GGRetryRoleMigrationArgs memory args = GGRetryRoleMigrationArgs({
      granularGuardian: GRANULAR_GUARDIAN(),
      newRetryGuardian: NEW_RETRY_GUARDIAN()
    });
    return _deployPayload(args);
  }

  function _getNewRetryGuardian() internal pure override returns (address) {
    return NEW_RETRY_GUARDIAN();
  }
}

// TODO: add block number
contract EthereumTest is Ethereum, BaseGGRetryRoleMigrationTest('ethereum', 10000000) {
  function _getGranularGuardian() internal pure override returns (address) {
    return GovernanceV3Ethereum.GRANULAR_GUARDIAN;
  }

  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Ethereum.CROSS_CHAIN_CONTROLLER;
  }

  function CURRENT_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0xb812d0944f8F581DfAA3a93Dda0d22EcEf51A9CF; // BGD guardian
  }

  function _getDeployedPayload() internal pure override returns (address) {
    return address(0); // TODO: add deployed payload address
  }

  function _getPayload() internal override returns (address) {
    GGRetryRoleMigrationArgs memory args = GGRetryRoleMigrationArgs({
      granularGuardian: GRANULAR_GUARDIAN(),
      newRetryGuardian: NEW_RETRY_GUARDIAN()
    });
    return _deployPayload(args);
  }

  function _getNewRetryGuardian() internal pure override returns (address) {
    return NEW_RETRY_GUARDIAN();
  }
}

// TODO: add block number
contract GnosisTest is Gnosis, BaseGGRetryRoleMigrationTest('gnosis', 10000000) {
  function _getGranularGuardian() internal pure override returns (address) {
    return GovernanceV3Gnosis.GRANULAR_GUARDIAN;
  }

  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Gnosis.CROSS_CHAIN_CONTROLLER;
  }

  function CURRENT_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0xcb8a3E864D12190eD2b03cbA0833b15f2c314Ed8; // BGD guardian
  }
  function _getDeployedPayload() internal pure override returns (address) {
    return address(0); // TODO: add deployed payload address
  }

  function _getPayload() internal override returns (address) {
    GGRetryRoleMigrationArgs memory args = GGRetryRoleMigrationArgs({
      granularGuardian: GRANULAR_GUARDIAN(),
      newRetryGuardian: NEW_RETRY_GUARDIAN()
    });
    return _deployPayload(args);
  }

  function _getNewRetryGuardian() internal pure override returns (address) {
    return NEW_RETRY_GUARDIAN();
  }
}

// TODO: add block number
contract InkTest is Ink, BaseGGRetryRoleMigrationTest('ink', 10000000) {
  function _getGranularGuardian() internal pure override returns (address) {
    return GovernanceV3Ink.GRANULAR_GUARDIAN;
  }

  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Ink.CROSS_CHAIN_CONTROLLER;
  }

  function CURRENT_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x81D251dA015A0C7bD882918Ca1ec6B7B8E094585; // BGD guardian
  }

  function _getDeployedPayload() internal pure override returns (address) {
    return address(0); // TODO: add deployed payload address
  }

  function _getPayload() internal override returns (address) {
    GGRetryRoleMigrationArgs memory args = GGRetryRoleMigrationArgs({
      granularGuardian: GRANULAR_GUARDIAN(),
      newRetryGuardian: NEW_RETRY_GUARDIAN()
    });
    return _deployPayload(args);
  }

  function _getNewRetryGuardian() internal pure override returns (address) {
    return NEW_RETRY_GUARDIAN();
  }
}

// TODO: add block number
contract LineaTest is Linea, BaseGGRetryRoleMigrationTest('linea', 10000000) {
  function _getGranularGuardian() internal pure override returns (address) {
    return GovernanceV3Linea.GRANULAR_GUARDIAN;
  }

  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Linea.CROSS_CHAIN_CONTROLLER;
  }

  function CURRENT_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0xfD3a6E65e470a7D7D730FFD5D36a9354E8F9F4Ea; // BGD guardian
  }
  function _getDeployedPayload() internal pure override returns (address) {
    return address(0); // TODO: add deployed payload address
  }

  function _getPayload() internal override returns (address) {
    GGRetryRoleMigrationArgs memory args = GGRetryRoleMigrationArgs({
      granularGuardian: GRANULAR_GUARDIAN(),
      newRetryGuardian: NEW_RETRY_GUARDIAN()
    });
    return _deployPayload(args);
  }

  function _getNewRetryGuardian() internal pure override returns (address) {
    return NEW_RETRY_GUARDIAN();
  }
}

// TODO: add block number
contract MantleTest is Mantle, BaseGGRetryRoleMigrationTest('mantle', 10000000) {
  function _getGranularGuardian() internal pure override returns (address) {
    return GovernanceV3Mantle.GRANULAR_GUARDIAN;
  }

  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Mantle.CROSS_CHAIN_CONTROLLER;
  }

  function CURRENT_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x0686f59Cc2aEc1ccf891472Dc6C89bB747F6a4A7; // BGD guardian
  }

  function _getDeployedPayload() internal pure override returns (address) {
    return address(0); // TODO: add deployed payload address
  }

  function _getPayload() internal override returns (address) {
    GGRetryRoleMigrationArgs memory args = GGRetryRoleMigrationArgs({
      granularGuardian: GRANULAR_GUARDIAN(),
      newRetryGuardian: NEW_RETRY_GUARDIAN()
    });
    return _deployPayload(args);
  }

  function _getNewRetryGuardian() internal pure override returns (address) {
    return NEW_RETRY_GUARDIAN();
  }
}

contract MegaethTest is Megaeth, BaseGGRetryRoleMigrationTest('megaeth', 10000000) {
  function _getGranularGuardian() internal pure override returns (address) {
    return GovernanceV3MegaEth.GRANULAR_GUARDIAN;
  }

  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3MegaEth.CROSS_CHAIN_CONTROLLER;
  }

  function CURRENT_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x58528Cd7B8E84520df4D3395249D24543f431c21; // BGD guardian
  }

  function _getDeployedPayload() internal pure override returns (address) {
    return address(0); // TODO: add deployed payload address
  }

  function _getPayload() internal override returns (address) {
    GGRetryRoleMigrationArgs memory args = GGRetryRoleMigrationArgs({
      granularGuardian: GRANULAR_GUARDIAN(),
      newRetryGuardian: NEW_RETRY_GUARDIAN()
    });
    return _deployPayload(args);
  }

  function _getNewRetryGuardian() internal pure override returns (address) {
    return NEW_RETRY_GUARDIAN();
  }
}

// contract Metis is GG_retry_role_migration {
//   function GRANULAR_GUARDIAN() internal pure override returns (address) {
//     return GovernanceV3Metis.GRANULAR_GUARDIAN;
//   }

//   function CURRENT_RETRY_GUARDIAN() internal pure override returns (address) {
//     return 0x9853589F951D724D9f7c6724E0fD63F9d888C429; // BGD guardian
//   }

//   function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
//     return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
//   }
// }

contract OptimismTest is Optimism, BaseGGRetryRoleMigrationTest('optimism', 10000000) {
  function _getGranularGuardian() internal pure override returns (address) {
    return GovernanceV3Optimism.GRANULAR_GUARDIAN;
  }

  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Optimism.CROSS_CHAIN_CONTROLLER;
  }

  function CURRENT_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x3A800fbDeAC82a4d9c68A9FA0a315e095129CDBF; // BGD guardian
  }

  function _getDeployedPayload() internal pure override returns (address) {
    return address(0); // TODO: add deployed payload address
  }

  function _getPayload() internal override returns (address) {
    GGRetryRoleMigrationArgs memory args = GGRetryRoleMigrationArgs({
      granularGuardian: GRANULAR_GUARDIAN(),
      newRetryGuardian: NEW_RETRY_GUARDIAN()
    });
    return _deployPayload(args);
  }

  function _getNewRetryGuardian() internal pure override returns (address) {
    return NEW_RETRY_GUARDIAN();
  }
}

contract PlasmaTest is Plasma, BaseGGRetryRoleMigrationTest('plasma', 10000000) {
  function _getGranularGuardian() internal pure override returns (address) {
    return GovernanceV3Plasma.GRANULAR_GUARDIAN;
  }

  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Plasma.CROSS_CHAIN_CONTROLLER;
  }

  function CURRENT_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0xdc62E0e65b2251Dc66404ca717FD32dcC365Be3A; // BGD guardian
  }

  function _getDeployedPayload() internal pure override returns (address) {
    return address(0); // TODO: add deployed payload address
  }

  function _getPayload() internal override returns (address) {
    GGRetryRoleMigrationArgs memory args = GGRetryRoleMigrationArgs({
      granularGuardian: GRANULAR_GUARDIAN(),
      newRetryGuardian: NEW_RETRY_GUARDIAN()
    });
    return _deployPayload(args);
  }

  function _getNewRetryGuardian() internal pure override returns (address) {
    return NEW_RETRY_GUARDIAN();
  }
}

contract PolygonTest is Polygon, BaseGGRetryRoleMigrationTest('polygon', 10000000) {
  function _getGranularGuardian() internal pure override returns (address) {
    return GovernanceV3Polygon.GRANULAR_GUARDIAN;
  }

  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Polygon.CROSS_CHAIN_CONTROLLER;
  }

  function CURRENT_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0xbCEB4f363f2666E2E8E430806F37e97C405c130b; // BGD guardian
  }

  function _getDeployedPayload() internal pure override returns (address) {
    return address(0); // TODO: add deployed payload address
  }

  function _getPayload() internal override returns (address) {
    GGRetryRoleMigrationArgs memory args = GGRetryRoleMigrationArgs({
      granularGuardian: GRANULAR_GUARDIAN(),
      newRetryGuardian: NEW_RETRY_GUARDIAN()
    });
    return _deployPayload(args);
  }

  function _getNewRetryGuardian() internal pure override returns (address) {
    return NEW_RETRY_GUARDIAN();
  }
}

contract ScrollTest is Scroll, BaseGGRetryRoleMigrationTest('scroll', 10000000) {
  function _getGranularGuardian() internal pure override returns (address) {
    return GovernanceV3Scroll.GRANULAR_GUARDIAN;
  }

  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Scroll.CROSS_CHAIN_CONTROLLER;
  }

  function CURRENT_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x4aAa03F0A61cf93eA252e987b585453578108358; // BGD guardian
  }

  function _getDeployedPayload() internal pure override returns (address) {
    return address(0); // TODO: add deployed payload address
  }

  function _getPayload() internal override returns (address) {
    GGRetryRoleMigrationArgs memory args = GGRetryRoleMigrationArgs({
      granularGuardian: GRANULAR_GUARDIAN(),
      newRetryGuardian: NEW_RETRY_GUARDIAN()
    });
    return _deployPayload(args);
  }

  function _getNewRetryGuardian() internal pure override returns (address) {
    return NEW_RETRY_GUARDIAN();
  }
}

// contract Soneium is GG_retry_role_migration {
//   function GRANULAR_GUARDIAN() internal pure override returns (address) {
//     return GovernanceV3Soneium.GRANULAR_GUARDIAN;
//   }

//   function CURRENT_RETRY_GUARDIAN() internal pure override returns (address) {
//     return 0xdc62E0e65b2251Dc66404ca717FD32dcC365Be3A; // BGD guardian
//   }

//   function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
//     return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
//   }
// }

contract SonicTest is Sonic, BaseGGRetryRoleMigrationTest('sonic', 10000000) {
  function _getGranularGuardian() internal pure override returns (address) {
    return GovernanceV3Sonic.GRANULAR_GUARDIAN;
  }

  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3Sonic.CROSS_CHAIN_CONTROLLER;
  }

  function CURRENT_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x7837d7a167732aE41627A3B829871d9e32e2e7f2; // BGD guardian
  }

  function _getDeployedPayload() internal pure override returns (address) {
    return address(0); // TODO: add deployed payload address
  }

  function _getPayload() internal override returns (address) {
    GGRetryRoleMigrationArgs memory args = GGRetryRoleMigrationArgs({
      granularGuardian: GRANULAR_GUARDIAN(),
      newRetryGuardian: NEW_RETRY_GUARDIAN()
    });
    return _deployPayload(args);
  }
  function _getNewRetryGuardian() internal pure override returns (address) {
    return NEW_RETRY_GUARDIAN();
  }
}

contract XlayerTest is Xlayer, BaseGGRetryRoleMigrationTest('xlayer', 10000000) {
  function _getGranularGuardian() internal pure override returns (address) {
    return GovernanceV3XLayer.GRANULAR_GUARDIAN;
  }

  function CROSS_CHAIN_CONTROLLER() internal pure override returns (address) {
    return GovernanceV3XLayer.CROSS_CHAIN_CONTROLLER;
  }

  function CURRENT_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x734c3fF8DE95c3745770df69053A31FDC92F2526; // BGD guardian
  }

  function _getDeployedPayload() internal pure override returns (address) {
    return address(0); // TODO: add deployed payload address
  }

  function _getPayload() internal override returns (address) {
    GGRetryRoleMigrationArgs memory args = GGRetryRoleMigrationArgs({
      granularGuardian: GRANULAR_GUARDIAN(),
      newRetryGuardian: NEW_RETRY_GUARDIAN()
    });
    return _deployPayload(args);
  }

  function _getNewRetryGuardian() internal pure override returns (address) {
    return NEW_RETRY_GUARDIAN();
  }
}
