// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseDeployerScript.sol';
import {TransparentProxyFactory} from 'solidity-utils/contracts/transparent-proxy/TransparentProxyFactory.sol';
import 'adi-scripts/CCC/DeployCrossChainController.sol';

abstract contract BaseCCCNetworkDeployment is BaseDeployerScript, BaseCCCDeploy {
  function _execute(Addresses memory addresses) internal override {
    addresses.crossChainControllerImpl = _deployCCCImpl();
    address crossChainController;
    // if address is 0 means that ccc will not be emergency consumer
    if (CL_EMERGENCY_ORACLE() == address(0)) {
      crossChainController = TransparentProxyFactory(addresses.proxyFactory).createDeterministic(
        addresses.crossChainControllerImpl,
        addresses.executor, // owner of the proxy admin
        abi.encodeWithSelector(
          CrossChainController.initialize.selector,
          addresses.owner,
          addresses.guardian,
          new ICrossChainController.ConfirmationInput[](0),
          new ICrossChainController.ReceiverBridgeAdapterConfigInput[](0),
          new ICrossChainController.ForwarderBridgeAdapterConfigInput[](0),
          new address[](0),
          new ICrossChainController.OptimalBandwidthByChain[](0)
        ),
        keccak256(abi.encode(SALT()))
      );
    } else {
      crossChainController = TransparentProxyFactory(addresses.proxyFactory).createDeterministic(
        addresses.crossChainControllerImpl,
        addresses.executor,
        abi.encodeWithSelector(
          ICrossChainControllerWithEmergencyMode.initialize.selector,
          addresses.owner,
          addresses.guardian,
          CL_EMERGENCY_ORACLE(),
          new ICrossChainController.ConfirmationInput[](0),
          new ICrossChainController.ReceiverBridgeAdapterConfigInput[](0),
          new ICrossChainController.ForwarderBridgeAdapterConfigInput[](0),
          new address[](0),
          new ICrossChainController.OptimalBandwidthByChain[](0)
        ),
        keccak256(abi.encode(SALT()))
      );

      addresses.clEmergencyOracle = CL_EMERGENCY_ORACLE();
    }

    addresses.proxyAdminCCC = TransparentProxyFactory(addresses.proxyFactory).getProxyAdmin(
      crossChainController
    );
    addresses.crossChainController = crossChainController;
  }
}

contract Ethereum is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }
}

contract Polygon is BaseCCCNetworkDeployment {
  function CL_EMERGENCY_ORACLE() internal pure override returns (address) {
    return 0xDAFA1989A504c48Ee20a582f2891eeB25E2fA23F;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.POLYGON;
  }
}

contract Avalanche is BaseCCCNetworkDeployment {
  function CL_EMERGENCY_ORACLE() internal pure override returns (address) {
    return 0x41185495Bc8297a65DC46f94001DC7233775EbEe;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.AVALANCHE;
  }
}

contract Arbitrum is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ARBITRUM;
  }
}

contract Optimism is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.OPTIMISM;
  }
}

contract Metis is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.METIS;
  }
}

contract Binance is BaseCCCNetworkDeployment {
  function CL_EMERGENCY_ORACLE() internal pure override returns (address) {
    return 0xcabb46FfB38c93348Df16558DF156e9f68F9F7F1;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.BNB;
  }
}

contract Base is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.BASE;
  }
}

contract Gnosis is BaseCCCNetworkDeployment {
  function CL_EMERGENCY_ORACLE() internal pure override returns (address) {
    return 0xF937ffAeA1363e4Fa260760bDFA2aA8Fc911F84D;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.GNOSIS;
  }
}

contract Zkevm is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.POLYGON_ZK_EVM;
  }
}

contract Scroll is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.SCROLL;
  }
}

contract Celo is BaseCCCNetworkDeployment {
  function CL_EMERGENCY_ORACLE() internal pure override returns (address) {
    return 0x91b21900E91CD302EBeD05E45D8f270ddAED944d;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.CELO;
  }
}

contract Zksync is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ZKSYNC;
  }
}

contract Linea is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.LINEA;
  }
}

contract Sonic is BaseCCCNetworkDeployment {
  function CL_EMERGENCY_ORACLE() internal pure override returns (address) {
    return 0xECB564e91f620fBFb59d0C4A41d7f10aDb0D1934;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.SONIC;
  }
}

contract Ink is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.INK;
  }
}

contract Mantle is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.MANTLE;
  }
}

contract Ethereum_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }
}

contract Polygon_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.POLYGON_AMOY;
  }
}

contract Avalanche_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.AVALANCHE_FUJI;
  }
}

contract Arbitrum_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.ARBITRUM_SEPOLIA;
  }
}

contract Optimism_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.OPTIMISM_SEPOLIA;
  }
}

contract Metis_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.METIS_TESTNET;
  }
}

contract Binance_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.BNB_TESTNET;
  }
}

contract Base_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.BASE_SEPOLIA;
  }
}

contract Gnosis_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.GNOSIS_CHIADO;
  }
}

contract Scroll_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.SCROLL_SEPOLIA;
  }
}

contract Celo_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.CELO_ALFAJORES;
  }
}

contract Linea_testnet is BaseCCCNetworkDeployment {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return TestNetChainIds.LINEA_SEPOLIA;
  }
}
