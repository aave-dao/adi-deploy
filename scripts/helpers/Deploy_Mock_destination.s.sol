// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseDeployerScript.sol';
import 'adi-scripts/contract_extensions/MockDestination.sol';

abstract contract BaseMockDestination is BaseDeployerScript {
  function _execute(Addresses memory addresses) internal override {
    addresses.mockDestination = address(new MockDestination(addresses.crossChainController));
  }
}

contract Ethereum is BaseMockDestination {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}

contract Avalanche is BaseMockDestination {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.AVALANCHE;
  }
}

contract Polygon is BaseMockDestination {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.POLYGON;
  }
}

contract Optimism is BaseMockDestination {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.OPTIMISM;
  }
}

contract Arbitrum is BaseMockDestination {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.ARBITRUM;
  }
}

contract Metis is BaseMockDestination {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.METIS;
  }
}

contract Base is BaseMockDestination {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.BASE;
  }
}

contract Binance is BaseMockDestination {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.BNB;
  }
}

contract Gnosis is BaseMockDestination {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.GNOSIS;
  }
}

contract Celo is BaseMockDestination {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.CELO;
  }
}

contract Scroll is BaseMockDestination {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.SCROLL;
  }
}

contract Zksync is BaseMockDestination {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.ZKSYNC;
  }
}

contract Linea is BaseMockDestination {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.LINEA;
  }
}

contract Mantle is BaseMockDestination {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.MANTLE;
  }
}

contract Ink is BaseMockDestination {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.INK;
  }
}

contract Soneium is BaseMockDestination {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.SONEIUM;
  }
}

contract Bob is BaseMockDestination {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.BOB;
  }
}

contract Plasma is BaseMockDestination {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.PLASMA;
  }
}

contract Xlayer is BaseMockDestination {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.XLAYER;
  }
}
