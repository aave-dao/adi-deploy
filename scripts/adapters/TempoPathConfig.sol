// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @dev settings shared by the Ethereum adapters dedicated to the Ethereum -> Tempo path
library TempoPathConfig {
  /**
   * @dev becomes the immutable BASE_GAS_LIMIT of the Ethereum CCIP, Hyperlane and Wormhole Executor adapters
   * used only towards Tempo. The Ethereum CrossChainController delegatecalls the adapter's forwardMessage,
   * so this value, added to the 300k governance gas limit, is the gas each bridge delivers with on Tempo.
   * 300k total was too little for CCIP delivery on Tempo, which charges more gas for state creation.
   */
  uint256 internal constant ETHEREUM_PROVIDER_GAS_LIMIT = 700_000;
}
