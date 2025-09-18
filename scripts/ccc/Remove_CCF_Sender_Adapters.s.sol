// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseDeployerScript.sol';
import {ICrossChainForwarder} from 'adi/interfaces/ICrossChainForwarder.sol';
import {ICrossChainReceiver} from 'adi/interfaces/ICrossChainReceiver.sol';

abstract contract BaseDisableCCFAdapter is BaseDeployerScript {
  function getBridgeAdaptersToDisable()
  public
  pure
  virtual
  returns (ICrossChainForwarder.BridgeAdapterToDisable[] memory);

  function _execute(Addresses memory addresses) internal override {
    ICrossChainForwarder(addresses.crossChainController).disableBridgeAdapters(
      getBridgeAdaptersToDisable()
    );
  }
}
