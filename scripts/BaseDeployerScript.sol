// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'adi-scripts/BaseScript.sol';
import {ChainHelpers} from 'solidity-utils/contracts/utils/ChainHelpers.sol';

struct Addresses {
  address arbAdapter;
  address baseAdapter;
  address bobAdapter;
  address ccipAdapter;
  uint256 chainId;
  address clEmergencyOracle;
  address create3Factory;
  address crossChainController;
  address crossChainControllerImpl;
  address emergencyRegistry;
  address executor;
  address gnosisAdapter;
  address granularCCCGuardian;
  address guardian;
  address hlAdapter;
  address inkAdapter;
  address lineaAdapter;
  address lzAdapter;
  address mantleAdapter;
  address metisAdapter;
  address mockDestination;
  address opAdapter;
  address owner;
  address polAdapter;
  address proxyAdminCCC;
  address proxyFactory;
  address sameChainAdapter;
  address scrollAdapter;
  address soneiumAdapter;
  address wormholeAdapter;
  address zkevmAdapter;
  address zksyncAdapter;
}

library DeployerHelpers {
  using stdJson for string;

  function getPathByChainId(uint256 chainId) internal pure returns (string memory) {
    string memory path = string.concat(
      './deployments/cc/mainnet/', // @dev important to maintain this folder structure as governance uses this path to get the adi addresses
      ChainHelpers.getNetworkNameFromId(chainId)
    );
    return string.concat(path, '.json');
  }

  function decodeJson(string memory path, VmSafe vm) internal view returns (Addresses memory) {
    string memory persistedJson = vm.readFile(path);

    Addresses memory addresses = Addresses({
      proxyAdminCCC: abi.decode(persistedJson.parseRaw('.proxyAdminCCC'), (address)),
      proxyFactory: abi.decode(persistedJson.parseRaw('.proxyFactory'), (address)),
      owner: abi.decode(persistedJson.parseRaw('.owner'), (address)),
      guardian: abi.decode(persistedJson.parseRaw('.guardian'), (address)),
      clEmergencyOracle: abi.decode(persistedJson.parseRaw('.clEmergencyOracle'), (address)),
      create3Factory: abi.decode(persistedJson.parseRaw('.create3Factory'), (address)),
      crossChainController: abi.decode(persistedJson.parseRaw('.crossChainController'), (address)),
      crossChainControllerImpl: abi.decode(
        persistedJson.parseRaw('.crossChainControllerImpl'),
        (address)
      ),
      ccipAdapter: abi.decode(persistedJson.parseRaw('.ccipAdapter'), (address)),
      sameChainAdapter: abi.decode(persistedJson.parseRaw('.sameChainAdapter'), (address)),
      chainId: abi.decode(persistedJson.parseRaw('.chainId'), (uint256)),
      emergencyRegistry: abi.decode(persistedJson.parseRaw('.emergencyRegistry'), (address)),
      executor: abi.decode(persistedJson.parseRaw('.executor'), (address)),
      lineaAdapter: abi.decode(persistedJson.parseRaw('.lineaAdapter'), (address)),
      lzAdapter: abi.decode(persistedJson.parseRaw('.lzAdapter'), (address)),
      hlAdapter: abi.decode(persistedJson.parseRaw('.hlAdapter'), (address)),
      inkAdapter: abi.decode(persistedJson.parseRaw('.inkAdapter'), (address)),
      opAdapter: abi.decode(persistedJson.parseRaw('.opAdapter'), (address)),
      arbAdapter: abi.decode(persistedJson.parseRaw('.arbAdapter'), (address)),
      metisAdapter: abi.decode(persistedJson.parseRaw('.metisAdapter'), (address)),
      polAdapter: abi.decode(persistedJson.parseRaw('.polAdapter'), (address)),
      mockDestination: abi.decode(persistedJson.parseRaw('.mockDestination'), (address)),
      baseAdapter: abi.decode(persistedJson.parseRaw('.baseAdapter'), (address)),
      zkevmAdapter: abi.decode(persistedJson.parseRaw('.zkevmAdapter'), (address)),
      gnosisAdapter: abi.decode(persistedJson.parseRaw('.gnosisAdapter'), (address)),
      scrollAdapter: abi.decode(persistedJson.parseRaw('.scrollAdapter'), (address)),
      soneiumAdapter: abi.decode(persistedJson.parseRaw('.soneiumAdapter'), (address)),
      wormholeAdapter: abi.decode(persistedJson.parseRaw('.wormholeAdapter'), (address)),
      zksyncAdapter: abi.decode(persistedJson.parseRaw('.zksyncAdapter'), (address)),
      mantleAdapter: abi.decode(persistedJson.parseRaw('.mantleAdapter'), (address)),
      bobAdapter: abi.decode(persistedJson.parseRaw('.bobAdapter'), (address)),
      granularCCCGuardian: abi.decode(persistedJson.parseRaw('.granularCCCGuardian'), (address))
    });

    return addresses;
  }

  function encodeJson(string memory path, Addresses memory addresses, VmSafe vm) internal {
    string memory json = 'addresses';
    json.serialize('arbAdapter', addresses.arbAdapter);
    json.serialize('baseAdapter', addresses.baseAdapter);
    json.serialize('bobAdapter', addresses.bobAdapter);
    json.serialize('ccipAdapter', addresses.ccipAdapter);
    json.serialize('chainId', addresses.chainId);
    json.serialize('clEmergencyOracle', addresses.clEmergencyOracle);
    json.serialize('create3Factory', addresses.create3Factory);
    json.serialize('crossChainController', addresses.crossChainController);
    json.serialize('crossChainControllerImpl', addresses.crossChainControllerImpl);
    json.serialize('emergencyRegistry', addresses.emergencyRegistry);
    json.serialize('executor', addresses.executor);
    json.serialize('gnosisAdapter', addresses.gnosisAdapter);
    json.serialize('guardian', addresses.guardian);
    json.serialize('granularCCCGuardian', addresses.granularCCCGuardian);
    json.serialize('hlAdapter', addresses.hlAdapter);
    json.serialize('inkAdapter', addresses.inkAdapter);
    json.serialize('lineaAdapter', addresses.lineaAdapter);
    json.serialize('lzAdapter', addresses.lzAdapter);
    json.serialize('mantleAdapter', addresses.mantleAdapter);
    json.serialize('metisAdapter', addresses.metisAdapter);
    json.serialize('mockDestination', addresses.mockDestination);
    json.serialize('opAdapter', addresses.opAdapter);
    json.serialize('owner', addresses.owner);
    json.serialize('polAdapter', addresses.polAdapter);
    json.serialize('proxyAdminCCC', addresses.proxyAdminCCC);
    json.serialize('proxyFactory', addresses.proxyFactory);
    json.serialize('sameChainAdapter', addresses.sameChainAdapter);
    json.serialize('scrollAdapter', addresses.scrollAdapter);
    json.serialize('soneiumAdapter', addresses.soneiumAdapter);
    json.serialize('wormholeAdapter', addresses.wormholeAdapter);
    json.serialize('zkevmAdapter', addresses.zkevmAdapter);
    json = json.serialize('zksyncAdapter', addresses.zksyncAdapter);
    vm.writeJson(json, path);
  }
}

abstract contract BaseDeployerScript is BaseScript, Script {
  function getAddresses(uint256 networkId) external view returns (Addresses memory) {
    return DeployerHelpers.decodeJson(DeployerHelpers.getPathByChainId(networkId), vm);
  }

  function _getAddresses(uint256 networkId) internal view returns (Addresses memory) {
    try this.getAddresses(networkId) returns (Addresses memory addresses) {
      return addresses;
    } catch (bytes memory) {
      Addresses memory empty;
      empty.chainId = TRANSACTION_NETWORK();
      return empty;
    }
  }

  function _execute(Addresses memory addresses) internal virtual;

  function _setAddresses(uint256 networkId, Addresses memory addresses) internal {
    DeployerHelpers.encodeJson(DeployerHelpers.getPathByChainId(networkId), addresses, vm);
  }

  function run() public virtual {
    vm.startBroadcast();
    // ----------------- Persist addresses -----------------------------------------------------------------------------
    Addresses memory addresses = _getAddresses(TRANSACTION_NETWORK());
    // -----------------------------------------------------------------------------------------------------------------
    _execute(addresses);
    // ----------------- Persist addresses -----------------------------------------------------------------------------
    _setAddresses(TRANSACTION_NETWORK(), addresses);
    // -----------------------------------------------------------------------------------------------------------------
    vm.stopBroadcast();
  }
}
