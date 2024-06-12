// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import 'adi-scripts/BaseScript.sol';
import {ChainHelpers} from 'aave-helpers/ChainIds.sol';

struct Addresses {
  address arbAdapter;
  address baseAdapter;
  address ccipAdapter;
  uint256 chainId;
  address clEmergencyOracle;
  address create3Factory;
  address crossChainController;
  address crossChainControllerImpl;
  address emergencyRegistry;
  address gnosisAdapter;
  address granularCCCGuardian;
  address guardian;
  address hlAdapter;
  address lzAdapter;
  address metisAdapter;
  address mockDestination;
  address opAdapter;
  address owner;
  address polAdapter;
  address proxyAdmin;
  address proxyFactory;
  address sameChainAdapter;
  address scrollAdapter;
  address wormholeAdapter;
  address zkevmAdapter;
  address zksyncAdapter;
}

library DeployerHelpers {
  using stdJson for string;

  function getPathByChainId(uint256 chainId) internal pure returns (string memory) {
    string memory path = string.concat(
      './deployments/',
      ChainHelpers.getNetworkNameFromId(chainId)
    );
    return string.concat(path, '.json');
  }

  function decodeJson(string memory path, VmSafe vm) internal view returns (Addresses memory) {
    string memory persistedJson = vm.readFile(path);

    Addresses memory addresses = Addresses({
      proxyAdmin: abi.decode(persistedJson.parseRaw('.proxyAdmin'), (address)),
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
      lzAdapter: abi.decode(persistedJson.parseRaw('.lzAdapter'), (address)),
      hlAdapter: abi.decode(persistedJson.parseRaw('.hlAdapter'), (address)),
      opAdapter: abi.decode(persistedJson.parseRaw('.opAdapter'), (address)),
      arbAdapter: abi.decode(persistedJson.parseRaw('.arbAdapter'), (address)),
      metisAdapter: abi.decode(persistedJson.parseRaw('.metisAdapter'), (address)),
      polAdapter: abi.decode(persistedJson.parseRaw('.polAdapter'), (address)),
      mockDestination: abi.decode(persistedJson.parseRaw('.mockDestination'), (address)),
      baseAdapter: abi.decode(persistedJson.parseRaw('.baseAdapter'), (address)),
      zkevmAdapter: abi.decode(persistedJson.parseRaw('.zkevmAdapter'), (address)),
      gnosisAdapter: abi.decode(persistedJson.parseRaw('.gnosisAdapter'), (address)),
      scrollAdapter: abi.decode(persistedJson.parseRaw('.scrollAdapter'), (address)),
      wormholeAdapter: abi.decode(persistedJson.parseRaw('.wormholeAdapter'), (address)),
      zksyncAdapter: abi.decode(persistedJson.parseRaw('.zksyncAdapter'), (address)),
      granularCCCGuardian: abi.decode(persistedJson.parseRaw('.granularCCCGuardian'), (address))
    });

    return addresses;
  }

  function encodeJson(string memory path, Addresses memory addresses, VmSafe vm) internal {
    string memory json = 'addresses';
    json.serialize('arbAdapter', addresses.arbAdapter);
    json.serialize('baseAdapter', addresses.baseAdapter);
    json.serialize('ccipAdapter', addresses.ccipAdapter);
    json.serialize('chainId', addresses.chainId);
    json.serialize('clEmergencyOracle', addresses.clEmergencyOracle);
    json.serialize('create3Factory', addresses.create3Factory);
    json.serialize('crossChainController', addresses.crossChainController);
    json.serialize('crossChainControllerImpl', addresses.crossChainControllerImpl);
    json.serialize('emergencyRegistry', addresses.emergencyRegistry);
    json.serialize('gnosisAdapter', addresses.gnosisAdapter);
    json.serialize('guardian', addresses.guardian);
    json.serialize('granularCCCGuardian', addresses.granularCCCGuardian);
    json.serialize('hlAdapter', addresses.hlAdapter);
    json.serialize('lzAdapter', addresses.lzAdapter);
    json.serialize('metisAdapter', addresses.metisAdapter);
    json.serialize('mockDestination', addresses.mockDestination);
    json.serialize('opAdapter', addresses.opAdapter);
    json.serialize('owner', addresses.owner);
    json.serialize('polAdapter', addresses.polAdapter);
    json.serialize('proxyAdmin', addresses.proxyAdmin);
    json.serialize('proxyFactory', addresses.proxyFactory);
    json.serialize('sameChainAdapter', addresses.sameChainAdapter);
    json.serialize('scrollAdapter', addresses.scrollAdapter);
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
