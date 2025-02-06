// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Addresses, Ethereum, Polygon, Avalanche, Arbitrum, Optimism, Metis, Binance, Base, Gnosis, Scroll} from '../../../scripts/payloads/ccc/shuffle/Network_Deployments.s.sol';
import '../../adi/ADITestBase.sol';
import 'forge-std/console.sol';

abstract contract BaseShufflePayloadTest is ADITestBase {
  address internal _payload;
  address internal _crossChainController;
  address internal _proxyAdmin;

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
    _proxyAdmin = addresses.proxyAdminCCC;

    _payload = _getPayload();
  }

  function test_defaultTest() public {
    defaultTest(
      string.concat('add_shuffle_to_ccc_', NETWORK),
      _crossChainController,
      address(_payload),
      false,
      vm
    );
  }
}

contract EthereumShufflePayloadTest is Ethereum, BaseShufflePayloadTest('ethereum', 20160500) {
  function _getDeployedPayload() internal pure override returns (address) {
    return 0xf50a100F8F60C3dC01a98a15231218accB3150C1;
  }

  function _getCurrentNetworkAddresses() internal view override returns (Addresses memory) {
    return _getAddresses(TRANSACTION_NETWORK());
  }

  function _getPayload() internal override returns (address) {
    return _deployPayload(_crossChainController, _proxyAdmin);
  }
}

contract PolygonShufflePayloadTest is Polygon, BaseShufflePayloadTest('polygon', 59181700) {
  function _getDeployedPayload() internal pure override returns (address) {
    return 0x5056B08129D788344F0BDbA4652E936c24229D9a;
  }

  function _getCurrentNetworkAddresses() internal view override returns (Addresses memory) {
    return _getAddresses(TRANSACTION_NETWORK());
  }

  function _getPayload() internal override returns (address) {
    return _deployPayload(_crossChainController, _proxyAdmin);
  }
}

contract AvalancheShufflePayloadTest is Avalanche, BaseShufflePayloadTest('avalanche', 47783432) {
  function _getDeployedPayload() internal pure override returns (address) {
    return 0xFAb9E283d3bf91Cb7732C869F31D97C9A7D1AEAB;
  }

  function _getCurrentNetworkAddresses() internal view override returns (Addresses memory) {
    return _getAddresses(TRANSACTION_NETWORK());
  }

  function _getPayload() internal override returns (address) {
    return _deployPayload(_crossChainController, _proxyAdmin);
  }
}

contract ArbitrumShufflePayloadTest is Arbitrum, BaseShufflePayloadTest('arbitrum', 230678009) {
  function _getDeployedPayload() internal pure override returns (address) {
    return 0x7ED073d35d8a1c6561102d75FA7aF0752a5ddC6e;
  }

  function _getCurrentNetworkAddresses() internal view override returns (Addresses memory) {
    return _getAddresses(TRANSACTION_NETWORK());
  }

  function _getPayload() internal override returns (address) {
    return _deployPayload(_crossChainController, _proxyAdmin);
  }
}

contract OptimismShufflePayloadTest is Optimism, BaseShufflePayloadTest('optimism', 122500476) {
  function _getDeployedPayload() internal pure override returns (address) {
    return 0x896607f9757B68A5432b8B8f2D79abdC2325d91C;
  }

  function _getCurrentNetworkAddresses() internal view override returns (Addresses memory) {
    return _getAddresses(TRANSACTION_NETWORK());
  }

  function _getPayload() internal override returns (address) {
    return _deployPayload(_crossChainController, _proxyAdmin);
  }
}

contract MetisShufflePayloadTest is Metis, BaseShufflePayloadTest('metis', 17614221) {
  function _getDeployedPayload() internal pure override returns (address) {
    return 0x82E898b0CDC997b44C704E42574906136E7B5fAd;
  }

  function _getCurrentNetworkAddresses() internal view override returns (Addresses memory) {
    return _getAddresses(TRANSACTION_NETWORK());
  }

  function _getPayload() internal override returns (address) {
    return _deployPayload(_crossChainController, _proxyAdmin);
  }
}

contract BinanceShufflePayloadTest is Binance, BaseShufflePayloadTest('binance', 40403127) {
  function _getDeployedPayload() internal pure override returns (address) {
    return 0x0853e4272f8AE9b8Be9439490df8Fb5A5c82DBF0;
  }

  function _getCurrentNetworkAddresses() internal view override returns (Addresses memory) {
    return _getAddresses(TRANSACTION_NETWORK());
  }

  function _getPayload() internal override returns (address) {
    return _deployPayload(_crossChainController, _proxyAdmin);
  }
}

contract CBaseShufflePayloadTest is Base, BaseShufflePayloadTest('base', 16905250) {
  function _getDeployedPayload() internal pure override returns (address) {
    return 0xc45BB75DB1bF012F9E06192aeA7D338FBe3271D8;
  }

  function _getCurrentNetworkAddresses() internal view override returns (Addresses memory) {
    return _getAddresses(TRANSACTION_NETWORK());
  }

  function _getPayload() internal override returns (address) {
    return _deployPayload(_crossChainController, _proxyAdmin);
  }
}

contract GnosisShufflePayloadTest is Gnosis, BaseShufflePayloadTest('gnosis', 34891878) {
  function _getDeployedPayload() internal pure override returns (address) {
    return 0x050bE7317a8D015E558E68A99e894375B00Bd723;
  }

  function _getCurrentNetworkAddresses() internal view override returns (Addresses memory) {
    return _getAddresses(TRANSACTION_NETWORK());
  }

  function _getPayload() internal override returns (address) {
    return _deployPayload(_crossChainController, _proxyAdmin);
  }
}

contract ScrollShufflePayloadTest is Scroll, BaseShufflePayloadTest('scroll', 7298668) {
  function _getDeployedPayload() internal pure override returns (address) {
    return 0x97d2bBBe4F87783D33FCabf56481c925C6c897e6;
  }

  function _getCurrentNetworkAddresses() internal view override returns (Addresses memory) {
    return _getAddresses(TRANSACTION_NETWORK());
  }

  function _getPayload() internal override returns (address) {
    return _deployPayload(_crossChainController, _proxyAdmin);
  }
}
