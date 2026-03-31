// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../../BaseDeployerScript.sol';
import {
  RetryRoleMigrationPayload,
  GGRetryRoleMigrationArgs
} from '../../../src/gg_payloads/RetryRoleMigrationPayload.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GovernanceV3Arbitrum} from 'aave-address-book/GovernanceV3Arbitrum.sol';
import {GovernanceV3Avalanche} from 'aave-address-book/GovernanceV3Avalanche.sol';
import {GovernanceV3Base} from 'aave-address-book/GovernanceV3Base.sol';
import {GovernanceV3BNB} from 'aave-address-book/GovernanceV3BNB.sol';
import {GovernanceV3Bob} from 'aave-address-book/GovernanceV3Bob.sol';
import {GovernanceV3Celo} from 'aave-address-book/GovernanceV3Celo.sol';
import {GovernanceV3Scroll} from 'aave-address-book/GovernanceV3Scroll.sol';
import {GovernanceV3Sonic} from 'aave-address-book/GovernanceV3Sonic.sol';
import {GovernanceV3XLayer} from 'aave-address-book/GovernanceV3XLayer.sol';
import {GovernanceV3MegaEth} from 'aave-address-book/GovernanceV3MegaEth.sol';
import {GovernanceV3Optimism} from 'aave-address-book/GovernanceV3Optimism.sol';
import {GovernanceV3Plasma} from 'aave-address-book/GovernanceV3Plasma.sol';
import {GovernanceV3Polygon} from 'aave-address-book/GovernanceV3Polygon.sol';
import {GovernanceV3Mantle} from 'aave-address-book/GovernanceV3Mantle.sol';
import {GovernanceV3Linea} from 'aave-address-book/GovernanceV3Linea.sol';
import {GovernanceV3Ink} from 'aave-address-book/GovernanceV3Ink.sol';
import {GovernanceV3Gnosis} from 'aave-address-book/GovernanceV3Gnosis.sol';

abstract contract GG_retry_role_migration is BaseDeployerScript {
  function PAYLOAD_SALT() internal pure virtual returns (string memory) {
    return 'GG retry role migration';
  }

  function GRANULAR_GUARDIAN() internal pure virtual returns (address);

  function NEW_RETRY_GUARDIAN() internal pure virtual returns (address);

  function _deployPayload(GGRetryRoleMigrationArgs memory args) internal returns (address) {
    bytes memory payloadByteCode = type(RetryRoleMigrationPayload).creationCode;
    bytes memory payloadCode = abi.encodePacked(payloadByteCode, abi.encode(args));

    return _deployByteCode(payloadCode, PAYLOAD_SALT());
  }

  function _execute(Addresses memory addresses) internal virtual override {
    _deployPayload(
      GGRetryRoleMigrationArgs({
        granularGuardian: GRANULAR_GUARDIAN(),
        newRetryGuardian: NEW_RETRY_GUARDIAN()
      })
    );
  }
}

contract Arbitrum is GG_retry_role_migration {
  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Arbitrum.GRANULAR_GUARDIAN;
  }

  function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ARBITRUM;
  }
}

contract Avalanche is GG_retry_role_migration {
  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Avalanche.GRANULAR_GUARDIAN;
  }

  function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.AVALANCHE;
  }
}

contract Base is GG_retry_role_migration {
  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Base.GRANULAR_GUARDIAN;
  }

  function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.BASE;
  }
}

contract Binance is GG_retry_role_migration {
  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3BNB.GRANULAR_GUARDIAN;
  }

  function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.BNB;
  }
}

contract Bob is GG_retry_role_migration {
  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Bob.GRANULAR_GUARDIAN;
  }

  function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.BOB;
  }
}

contract Celo is GG_retry_role_migration {
  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Celo.GRANULAR_GUARDIAN;
  }

  function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.CELO;
  }
}

contract Ethereum is GG_retry_role_migration {
  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Ethereum.GRANULAR_GUARDIAN;
  }

  function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}

contract Gnosis is GG_retry_role_migration {
  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Gnosis.GRANULAR_GUARDIAN;
  }

  function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.GNOSIS;
  }
}

contract Ink is GG_retry_role_migration {
  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Ink.GRANULAR_GUARDIAN;
  }

  function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.INK;
  }
}

contract Linea is GG_retry_role_migration {
  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Linea.GRANULAR_GUARDIAN;
  }

  function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.LINEA;
  }
}

contract Mantle is GG_retry_role_migration {
  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Mantle.GRANULAR_GUARDIAN;
  }

  function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.MANTLE;
  }
}

contract Megaeth is GG_retry_role_migration {
  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3MegaEth.GRANULAR_GUARDIAN;
  }

  function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.MEGAETH;
  }
}

// contract Metis is GG_retry_role_migration {
//   function GRANULAR_GUARDIAN() internal pure override returns (address) {
//     return GovernanceV3Metis.GRANULAR_GUARDIAN;
//   }

//   function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
//     return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
//   }
// }

contract Optimism is GG_retry_role_migration {
  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Optimism.GRANULAR_GUARDIAN;
  }

  function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.OPTIMISM;
  }
}

contract Plasma is GG_retry_role_migration {
  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Plasma.GRANULAR_GUARDIAN;
  }

  function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.PLASMA;
  }
}

contract Polygon is GG_retry_role_migration {
  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Polygon.GRANULAR_GUARDIAN;
  }

  function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.POLYGON;
  }
}

contract Scroll is GG_retry_role_migration {
  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Scroll.GRANULAR_GUARDIAN;
  }

  function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.SCROLL;
  }
}

// contract Soneium is GG_retry_role_migration {
//   function GRANULAR_GUARDIAN() internal pure override returns (address) {
//     return GovernanceV3Soneium.GRANULAR_GUARDIAN;
//   }

//   function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
//     return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
//   }
// }

contract Sonic is GG_retry_role_migration {
  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Sonic.GRANULAR_GUARDIAN;
  }

  function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.SONIC;
  }
}

contract Xlayer is GG_retry_role_migration {
  function GRANULAR_GUARDIAN() internal pure override returns (address) {
    return GovernanceV3XLayer.GRANULAR_GUARDIAN;
  }

  function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.XLAYER;
  }
}

// contract Zksync is GG_retry_role_migration {
//   function GRANULAR_GUARDIAN() internal pure override returns (address) {
//     return GovernanceV3ZkSync.GRANULAR_GUARDIAN;
//   }

//   function NEW_RETRY_GUARDIAN() internal pure override returns (address) {
//     return 0x0000000000000000000000000000000000001000; // TODO: add new guardian
//   }
// }
