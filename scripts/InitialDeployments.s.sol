// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import './BaseDeployerScript.sol';
import {
  TransparentProxyFactory
} from 'solidity-utils/contracts/transparent-proxy/TransparentProxyFactory.sol';
import {MiscArbitrum} from 'aave-address-book/MiscArbitrum.sol';
import {MiscAvalanche} from 'aave-address-book/MiscAvalanche.sol';
import {MiscBase} from 'aave-address-book/MiscBase.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {MiscOptimism} from 'aave-address-book/MiscOptimism.sol';
import {MiscPolygon} from 'aave-address-book/MiscPolygon.sol';
import {MiscMetis} from 'aave-address-book/MiscMetis.sol';
import {MiscGnosis} from 'aave-address-book/MiscGnosis.sol';
import {MiscBNB} from 'aave-address-book/MiscBNB.sol';
import {MiscScroll} from 'aave-address-book/MiscScroll.sol';
import {MiscCelo} from 'aave-address-book/MiscCelo.sol';
import {MiscSonic} from 'aave-address-book/MiscSonic.sol';
import {MiscMantle} from 'aave-address-book/MiscMantle.sol';
import {MiscZkSync} from 'aave-address-book/MiscZkSync.sol';
import {MiscLinea} from 'aave-address-book/MiscLinea.sol';
import {MiscInk} from 'aave-address-book/MiscInk.sol';
import {MiscSoneium} from 'aave-address-book/MiscSoneium.sol';
import {MiscPlasma} from 'aave-address-book/MiscPlasma.sol';
import {MiscBob} from 'aave-address-book/MiscBob.sol';
import {GovernanceV3Arbitrum} from 'aave-address-book/GovernanceV3Arbitrum.sol';
import {GovernanceV3Avalanche} from 'aave-address-book/GovernanceV3Avalanche.sol';
import {GovernanceV3Base} from 'aave-address-book/GovernanceV3Base.sol';
import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GovernanceV3Optimism} from 'aave-address-book/GovernanceV3Optimism.sol';
import {GovernanceV3Polygon} from 'aave-address-book/GovernanceV3Polygon.sol';
import {GovernanceV3Metis} from 'aave-address-book/GovernanceV3Metis.sol';
import {GovernanceV3BNB} from 'aave-address-book/GovernanceV3BNB.sol';
import {GovernanceV3Gnosis} from 'aave-address-book/GovernanceV3Gnosis.sol';
import {GovernanceV3Scroll} from 'aave-address-book/GovernanceV3Scroll.sol';
import {GovernanceV3Celo} from 'aave-address-book/GovernanceV3Celo.sol';
import {GovernanceV3Sonic} from 'aave-address-book/GovernanceV3Sonic.sol';
import {GovernanceV3Mantle} from 'aave-address-book/GovernanceV3Mantle.sol';
import {GovernanceV3ZkSync} from 'aave-address-book/GovernanceV3ZkSync.sol';
import {GovernanceV3Linea} from 'aave-address-book/GovernanceV3Linea.sol';
import {GovernanceV3Ink} from 'aave-address-book/GovernanceV3Ink.sol';
import {GovernanceV3Soneium} from 'aave-address-book/GovernanceV3Soneium.sol';
import {GovernanceV3Plasma} from 'aave-address-book/GovernanceV3Plasma.sol';
import {GovernanceV3Bob} from 'aave-address-book/GovernanceV3Bob.sol';

abstract contract BaseInitialDeployment is BaseDeployerScript {
  function OWNER() internal virtual returns (address) {
    return address(msg.sender); // as first owner we set deployer, this way its easier to configure
  }

  function GUARDIAN() internal virtual returns (address) {
    return address(msg.sender);
  }

  function TRANSPARENT_PROXY_FACTORY() internal pure virtual returns (address) {
    return address(0);
  }

  function EXECUTOR() internal virtual returns (address) {
    return address(0);
  }

  function SALT() internal pure returns (string memory) {
    return 'Proxy Admin';
  }

  function _execute(Addresses memory addresses) internal override {
    require(TRANSPARENT_PROXY_FACTORY() != address(0), 'Executor is not set');
    addresses.proxyFactory = TRANSPARENT_PROXY_FACTORY();
    require(EXECUTOR() != address(0), 'Executor is not set');
    addresses.executor = EXECUTOR();
    addresses.owner = OWNER();
    addresses.guardian = GUARDIAN();
    addresses.chainId = TRANSACTION_NETWORK();
  }
}

contract Ethereum is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return MiscEthereum.TRANSPARENT_PROXY_FACTORY;
  }

  function GUARDIAN() internal pure override returns (address) {
    return MiscEthereum.PROTOCOL_GUARDIAN;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}

contract Polygon is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return MiscPolygon.TRANSPARENT_PROXY_FACTORY;
  }

  function GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Polygon.GRANULAR_GUARDIAN;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.POLYGON;
  }
}

contract Avalanche is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return MiscAvalanche.TRANSPARENT_PROXY_FACTORY;
  }

  function GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Avalanche.GRANULAR_GUARDIAN;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.AVALANCHE;
  }
}

contract Optimism is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return MiscOptimism.TRANSPARENT_PROXY_FACTORY;
  }

  function GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Optimism.GRANULAR_GUARDIAN;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.OPTIMISM;
  }
}

contract Arbitrum is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return MiscArbitrum.TRANSPARENT_PROXY_FACTORY;
  }

  function GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Arbitrum.GRANULAR_GUARDIAN;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ARBITRUM;
  }
}

contract Metis is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return MiscMetis.TRANSPARENT_PROXY_FACTORY;
  }

  function GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Metis.GRANULAR_GUARDIAN;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.METIS;
  }
}

contract Binance is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return MiscBNB.TRANSPARENT_PROXY_FACTORY;
  }

  function GUARDIAN() internal pure override returns (address) {
    return GovernanceV3BNB.GRANULAR_GUARDIAN;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.BNB;
  }
}

contract Gnosis is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return MiscGnosis.TRANSPARENT_PROXY_FACTORY;
  }

  function GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Gnosis.GRANULAR_GUARDIAN;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.GNOSIS;
  }
}

contract Base is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return MiscBase.TRANSPARENT_PROXY_FACTORY;
  }

  function GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Base.GRANULAR_GUARDIAN;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.BASE;
  }
}

contract Scroll is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return MiscScroll.TRANSPARENT_PROXY_FACTORY;
  }

  function GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Scroll.GRANULAR_GUARDIAN;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.SCROLL;
  }
}

contract Celo is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return MiscCelo.TRANSPARENT_PROXY_FACTORY;
  }

  function GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Celo.GRANULAR_GUARDIAN;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.CELO;
  }
}

contract Sonic is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return MiscSonic.TRANSPARENT_PROXY_FACTORY;
  }

  function GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Sonic.GRANULAR_GUARDIAN;
  }

  function EXECUTOR() internal pure override returns (address) {
    return GovernanceV3Sonic.EXECUTOR_LVL_1;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.SONIC;
  }
}

contract Mantle is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return MiscMantle.TRANSPARENT_PROXY_FACTORY;
  }

  function GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Mantle.GRANULAR_GUARDIAN;
  }

  function EXECUTOR() internal pure override returns (address) {
    return GovernanceV3Mantle.EXECUTOR_LVL_1;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.MANTLE;
  }
}

contract Zksync is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return MiscZkSync.TRANSPARENT_PROXY_FACTORY;
  }

  function GUARDIAN() internal pure override returns (address) {
    return GovernanceV3ZkSync.GRANULAR_GUARDIAN;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ZKSYNC;
  }
}

contract Linea is BaseInitialDeployment {
  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return MiscLinea.TRANSPARENT_PROXY_FACTORY;
  }

  function GUARDIAN() internal pure override returns (address) {
    return GovernanceV3Linea.GRANULAR_GUARDIAN;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.LINEA;
  }
}

contract Ink is BaseInitialDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.INK;
  }

  function EXECUTOR() internal pure override returns (address) {
    return GovernanceV3Ink.EXECUTOR_LVL_1;
  }

  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return MiscInk.TRANSPARENT_PROXY_FACTORY;
  }
}

contract Soneium is BaseInitialDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.SONEIUM;
  }

  function EXECUTOR() internal pure override returns (address) {
    return GovernanceV3Soneium.EXECUTOR_LVL_1;
  }

  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return MiscSoneium.TRANSPARENT_PROXY_FACTORY;
  }
}

contract Bob is BaseInitialDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.BOB;
  }

  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return MiscBob.TRANSPARENT_PROXY_FACTORY;
  }

  function EXECUTOR() internal pure override returns (address) {
    return GovernanceV3Bob.EXECUTOR_LVL_1;
  }
}

contract Plasma is BaseInitialDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.PLASMA;
  }

  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return MiscPlasma.TRANSPARENT_PROXY_FACTORY;
  }

  function EXECUTOR() internal pure override returns (address) {
    return GovernanceV3Plasma.EXECUTOR_LVL_1;
  }
}

contract Xlayer is BaseInitialDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.XLAYER;
  }

  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return 0xEB0682d148e874553008730f0686ea89db7DA412; //MiscXlayer.TRANSPARENT_PROXY_FACTORY;
  }

  function EXECUTOR() internal pure override returns (address) {
    return 0xE2E8Badc5d50f8a6188577B89f50701cDE2D4e19; // GovernanceV3Xlayer.EXECUTOR_LVL_1;
  }
}

contract Megaeth is BaseInitialDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.MEGAETH;
  }

  function TRANSPARENT_PROXY_FACTORY() internal pure override returns (address) {
    return 0x0000000000000000000000000000000000000000; // MiscMegaeth.TRANSPARENT_PROXY_FACTORY;
  }

  function EXECUTOR() internal pure override returns (address) {
    return 0x0000000000000000000000000000000000000000; // GovernanceV3Megaeth.EXECUTOR_LVL_1;
  }
}
