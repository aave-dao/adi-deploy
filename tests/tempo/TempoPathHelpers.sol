// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Create2Utils} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {ChainIds} from 'solidity-utils/contracts/utils/ChainHelpers.sol';
import {TransparentUpgradeableProxy} from 'openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol';
import {ICrossChainController} from 'adi/interfaces/ICrossChainController.sol';
import {ICrossChainControllerWithEmergencyMode} from 'adi/interfaces/ICrossChainControllerWithEmergencyMode.sol';
import {CCCImplDeploymentHelper} from 'adi-scripts/CCC/DeployCrossChainController.sol';
import {Addresses} from '../../scripts/BaseDeployerScript.sol';
import {Tempo as TempoCCCScript} from '../../scripts/ccc/DeployCCC.s.sol';
import {Tempo as TempoCCIPScript, Ethereum_Tempo as EthereumTempoCCIPScript} from '../../scripts/adapters/DeployCCIPAdapter.s.sol';
import {Tempo as TempoHLScript, Ethereum_Tempo as EthereumTempoHLScript} from '../../scripts/adapters/DeployHL.s.sol';
import {Tempo as TempoWormholeScript, Ethereum_Tempo as EthereumTempoWormholeScript} from '../../scripts/adapters/DeployWormholeExecutor.s.sol';

/// @dev exposes the Tempo CCC deploy script's logic
contract TempoCCCDeployer is TempoCCCScript {
  function deploy(Addresses memory addresses) external returns (Addresses memory) {
    _execute(addresses);
    return addresses;
  }
}

/// @dev Tempo adapters' creation code for a given Tempo CCC, from the deploy scripts
contract TempoCCIPCode is TempoCCIPScript {
  function code(address tempoCCC) external view returns (bytes memory) {
    return _getAdapterByteCode(tempoCCC);
  }
}

contract TempoHLCode is TempoHLScript {
  function code(address tempoCCC) external view returns (bytes memory) {
    return _getAdapterByteCode(tempoCCC);
  }
}

contract TempoWormholeCode is TempoWormholeScript {
  function code(address tempoCCC) external view returns (bytes memory) {
    return _getAdapterByteCode(tempoCCC);
  }
}

/// @dev the Ethereum Tempo-path adapters' scripts, trusting a given Tempo CCC instead of deployments/tempo.json
contract EthereumTempoCCIPCode is EthereumTempoCCIPScript {
  address internal immutable _tempoCCC;

  constructor(address tempoCCC) {
    _tempoCCC = tempoCCC;
  }

  function TEMPO_CCC() internal view override returns (address) {
    return _tempoCCC;
  }
}

contract EthereumTempoHLCode is EthereumTempoHLScript {
  address internal immutable _tempoCCC;

  constructor(address tempoCCC) {
    _tempoCCC = tempoCCC;
  }

  function TEMPO_CCC() internal view override returns (address) {
    return _tempoCCC;
  }
}

contract EthereumTempoWormholeCode is EthereumTempoWormholeScript {
  address internal immutable _tempoCCC;

  constructor(address tempoCCC) {
    _tempoCCC = tempoCCC;
  }

  function TEMPO_CCC() internal view override returns (address) {
    return _tempoCCC;
  }
}

/**
 * @dev predicts the Tempo a.DI addresses. Every Tempo contract is deployed with CREATE2, so the addresses only
 * depend on the initial CCC owner and guardian (the deployer, until UpdateCCCPermissions runs). Tests use
 * TEMPO_DEPLOYER for both.
 */
abstract contract TempoPathHelpers {
  address internal constant TEMPO_DEPLOYER =
    address(uint160(uint256(keccak256('tempo a.DI deployer'))));

  address internal constant TEMPO_PROXY_FACTORY = 0xEB0682d148e874553008730f0686ea89db7DA412;
  address internal constant TEMPO_EXECUTOR = 0x502fDdcC5586cf94BD0D313798f2006984D53DAF;
  address internal constant TEMPO_CL_EMERGENCY_ORACLE = 0x0Bd931F734D4fA4F6e7566225Ce02B19996D8Ff4;
  address internal constant TEMPO_CCIP_ROUTER = 0xa132F089492CcE5f1D79483a9e4552f37266ed01;
  address internal constant TEMPO_HL_MAILBOX = 0x3a867fCfFeC2B790970eeBDC9023E75B0a172aa7;
  address internal constant TEMPO_WORMHOLE_CORE = 0xbebdb6C8ddC678FfA9f8748f85C815C556Dd8ac6;

  address internal constant ETHEREUM_CCC = 0xEd42a7D8559a463722Ca4beD50E0Cc05a386b0e1;

  bytes32 internal constant CCC_SALT = keccak256(abi.encode('a.DI CrossChainController'));
  bytes32 internal constant ADAPTER_SALT = keccak256(abi.encode('a.DI Adapter'));

  uint64 internal constant CCIP_SELECTOR_ETHEREUM = 5009297550715157269;
  uint16 internal constant WORMHOLE_ID_ETHEREUM = 2;

  function _tempoBaseAddresses() internal pure returns (Addresses memory addresses) {
    addresses.chainId = ChainIds.TEMPO;
    addresses.proxyFactory = TEMPO_PROXY_FACTORY;
    addresses.executor = TEMPO_EXECUTOR;
    addresses.owner = TEMPO_DEPLOYER;
    addresses.guardian = TEMPO_DEPLOYER;
  }

  function _predictTempoCCCImpl() internal pure returns (address) {
    return
      Create2Utils.computeCreate2Address(
        CCC_SALT,
        CCCImplDeploymentHelper.getCCCImplCode(TEMPO_CL_EMERGENCY_ORACLE)
      );
  }

  /// @dev same init data as scripts/ccc/DeployCCC.s.sol with an emergency oracle
  function _tempoCCCInitData() internal pure returns (bytes memory) {
    return
      abi.encodeWithSelector(
        ICrossChainControllerWithEmergencyMode.initialize.selector,
        TEMPO_DEPLOYER,
        TEMPO_DEPLOYER,
        TEMPO_CL_EMERGENCY_ORACLE,
        new ICrossChainController.ConfirmationInput[](0),
        new ICrossChainController.ReceiverBridgeAdapterConfigInput[](0),
        new ICrossChainController.ForwarderBridgeAdapterConfigInput[](0),
        new address[](0),
        new ICrossChainController.OptimalBandwidthByChain[](0)
      );
  }

  function _predictTempoCCC() internal pure returns (address) {
    bytes32 hash = keccak256(
      abi.encodePacked(
        bytes1(0xff),
        TEMPO_PROXY_FACTORY,
        CCC_SALT,
        keccak256(
          abi.encodePacked(
            type(TransparentUpgradeableProxy).creationCode,
            abi.encode(_predictTempoCCCImpl(), TEMPO_EXECUTOR, _tempoCCCInitData())
          )
        )
      )
    );
    return address(uint160(uint256(hash)));
  }

  function _tempoCCIPAdapterCode(address tempoCCC) internal returns (bytes memory) {
    return new TempoCCIPCode().code(tempoCCC);
  }

  function _tempoHLAdapterCode(address tempoCCC) internal returns (bytes memory) {
    return new TempoHLCode().code(tempoCCC);
  }

  function _tempoWormholeAdapterCode(address tempoCCC) internal returns (bytes memory) {
    return new TempoWormholeCode().code(tempoCCC);
  }

  /// @dev predicted Tempo adapters (ccipAdapter, hlAdapter, wormholeExecutorAdapter) for the predicted CCC
  function _predictTempoAddresses() internal returns (Addresses memory addresses) {
    addresses = _tempoBaseAddresses();
    addresses.crossChainController = _predictTempoCCC();
    addresses.ccipAdapter = Create2Utils.computeCreate2Address(
      ADAPTER_SALT,
      _tempoCCIPAdapterCode(addresses.crossChainController)
    );
    addresses.hlAdapter = Create2Utils.computeCreate2Address(
      ADAPTER_SALT,
      _tempoHLAdapterCode(addresses.crossChainController)
    );
    addresses.wormholeExecutorAdapter = Create2Utils.computeCreate2Address(
      ADAPTER_SALT,
      _tempoWormholeAdapterCode(addresses.crossChainController)
    );
  }
}
