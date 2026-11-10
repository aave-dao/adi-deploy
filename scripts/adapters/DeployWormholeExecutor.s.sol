// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'adi-scripts/Adapters/DeployWormholeExecutorAdapter.sol';
import '../BaseDeployerScript.sol';

// addresses: https://registry-api.wormholelabs.xyz/v1/public/deployments (w7/on-chain-quoter/quoter-router)
// and https://wormhole.com/docs/reference/contract-addresses/ (core)
abstract contract DeployWormholeExecutorAdapter is BaseDeployerScript, BaseWormholeExecutorAdapter {
  function _execute(Addresses memory addresses) internal override {
    addresses.wormholeExecutorAdapter = _deployAdapter(addresses.crossChainController);
  }

  /// @dev Wormhole Labs relay provider, registered on every quoter router used here
  function QUOTER() internal pure override returns (address) {
    return 0xa54008017941EcE968623a0Dd8Ee907E2b133596;
  }

  /// @dev creation code + constructor args, used to predict the CREATE2 address in tests
  function getAdapterCode() external view returns (bytes memory) {
    return _getAdapterByteCode(_getAddresses(TRANSACTION_NETWORK()).crossChainController);
  }
}

contract Ethereum is DeployWormholeExecutorAdapter {
  function WORMHOLE_CORE() internal pure override returns (address) {
    return 0x98f3c9e6E3fAce36bAAd05FE09d375Ef1464288B;
  }

  function EXECUTOR_QUOTER_ROUTER() internal pure override returns (address) {
    return 0xF22F1c0A3a8Cb42F695601731974784C499C4EF3;
  }

  function REFUND_ADDRESS() internal view override returns (address) {
    return _getAddresses(TRANSACTION_NETWORK()).crossChainController;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](2);
    remoteCCCByNetwork[0].chainId = ChainIds.POLYGON;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.POLYGON)
      .crossChainController;

    remoteCCCByNetwork[1].chainId = ChainIds.AVALANCHE;
    remoteCCCByNetwork[1].crossChainController = _getAddresses(ChainIds.AVALANCHE)
      .crossChainController;

    return remoteCCCByNetwork;
  }
}

abstract contract DeployRemoteWormholeExecutorAdapter is DeployWormholeExecutorAdapter {
  function REMOTE_CCC_BY_NETWORK() internal view override returns (RemoteCCC[] memory) {
    RemoteCCC[] memory remoteCCCByNetwork = new RemoteCCC[](1);
    remoteCCCByNetwork[0].chainId = ChainIds.ETHEREUM;
    remoteCCCByNetwork[0].crossChainController = _getAddresses(ChainIds.ETHEREUM)
      .crossChainController;

    return remoteCCCByNetwork;
  }
}

contract Polygon is DeployRemoteWormholeExecutorAdapter {
  function WORMHOLE_CORE() internal pure override returns (address) {
    return 0x7A4B5a56256163F07b2C80A7cA55aBE66c4ec4d7;
  }

  function EXECUTOR_QUOTER_ROUTER() internal pure override returns (address) {
    return 0x2a856931603930B827B1A4352FB4D66fA029F123;
  }

  function REFUND_ADDRESS() internal view override returns (address) {
    return _getAddresses(TRANSACTION_NETWORK()).crossChainController;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.POLYGON;
  }
}

contract Avalanche is DeployRemoteWormholeExecutorAdapter {
  function WORMHOLE_CORE() internal pure override returns (address) {
    return 0x54a8e5f9c4CbA08F9943965859F6c34eAF03E26c;
  }

  function EXECUTOR_QUOTER_ROUTER() internal pure override returns (address) {
    return 0xA3a2A615774d34c6a4dF443C488B084eacaBd2D0;
  }

  function REFUND_ADDRESS() internal view override returns (address) {
    return _getAddresses(TRANSACTION_NETWORK()).crossChainController;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.AVALANCHE;
  }
}

contract Binance is DeployRemoteWormholeExecutorAdapter {
  function WORMHOLE_CORE() internal pure override returns (address) {
    return 0x98f3c9e6E3fAce36bAAd05FE09d375Ef1464288B;
  }

  function EXECUTOR_QUOTER_ROUTER() internal pure override returns (address) {
    return 0xc921F293c27F332D47283174b11C872295624Edb;
  }

  /// @dev receive-only
  function REFUND_ADDRESS() internal pure override returns (address) {
    return address(0);
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.BNB;
  }
}

contract Monad is DeployRemoteWormholeExecutorAdapter {
  function WORMHOLE_CORE() internal pure override returns (address) {
    return 0x194B123c5E96B9b2E49763619985790Dc241CAC0;
  }

  function EXECUTOR_QUOTER_ROUTER() internal pure override returns (address) {
    return 0x3d9282A8e9a3cdd9b25AE969eff4705a1Fe75F34;
  }

  /// @dev receive-only
  function REFUND_ADDRESS() internal pure override returns (address) {
    return address(0);
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.MONAD;
  }
}
