// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import {DeployerHelpers, Addresses, ChainIds} from '../BaseDeployerScript.sol';
import {OwnableWithGuardian, IWithGuardian} from 'solidity-utils/contracts/access-control/OwnableWithGuardian.sol';

abstract contract UpdateCCCPermissions {
  function targetOwner() public view virtual returns (address);

  function targetADIGuardian() public view virtual returns (address);

  function aDIContractsToUpdate() public view virtual returns (address[] memory);

  function _changeOwnerAndGuardian(
    address owner,
    address guardian,
    address[] memory contracts
  ) internal {
    require(owner != address(0), 'NEW_OWNER_CANT_BE_0');
    require(guardian != address(0), 'NEW_GUARDIAN_CANT_BE_0');

    for (uint256 i = 0; i < contracts.length; i++) {
      OwnableWithGuardian contractWithAC = OwnableWithGuardian(contracts[i]);
      try contractWithAC.guardian() returns (address currentGuardian) {
        if (currentGuardian != guardian) {
          IWithGuardian(contracts[i]).updateGuardian(guardian);
        }
      } catch {}
      if (contractWithAC.owner() != owner) {
        contractWithAC.transferOwnership(owner);
      }
    }
  }

  function _changeOwnerAndGuardian() internal {
    _changeOwnerAndGuardian(targetOwner(), targetADIGuardian(), aDIContractsToUpdate());
  }
}

contract UpdateCCCPermissionsMantle is UpdateCCCPermissions {
  function targetOwner() public pure override returns (address) {
    return 0x70884634D0098782592111A2A6B8d223be31CB7b; // executor
  }

  function targetADIGuardian() public pure override returns (address) {
    return 0xb26670d2800DBB9cfCe2f2660FfDcA48C799c86d; // Granular Guardian
  }

  function aDIContractsToUpdate() public pure override returns (address[] memory) {
    address[] memory contracts = new address[](1);
    contracts[0] = 0x1283C5015B1Fb5616FA3aCb0C18e6879a02869cB; // CCC
    return contracts;
  }
}

contract Mantle is Script, UpdateCCCPermissionsMantle {
  function run() external {
    vm.startBroadcast();

    _changeOwnerAndGuardian();

    vm.stopBroadcast();
  }
}

contract UpdateCCCPermissionsInk is UpdateCCCPermissions {
  function targetOwner() public pure override returns (address) {
    return 0x47aAdaAE1F05C978E6aBb7568d11B7F6e0FC4d6A; // executor
  }

  function targetADIGuardian() public pure override returns (address) {
    return 0xa2bDB2335Faf1940c99654c592B1a80618d79Fc9; // Granular Guardian
  }

  function aDIContractsToUpdate() public pure override returns (address[] memory) {
    address[] memory contracts = new address[](1);
    contracts[0] = 0x990B75fD1a2345D905a385dBC6e17BEe0Cb2f505; // CCC
    return contracts;
  }
}

contract Ink is Script, UpdateCCCPermissionsInk {
  function run() external {
    vm.startBroadcast();

    _changeOwnerAndGuardian();

    vm.stopBroadcast();
  }
}

contract UpdateCCCPermissionsSoneium is UpdateCCCPermissions {
  function targetOwner() public pure override returns (address) {
    return 0x47aAdaAE1F05C978E6aBb7568d11B7F6e0FC4d6A; // executor
  }

  function targetADIGuardian() public pure override returns (address) {
    return 0xD8E6956718784B914740267b7A50B952fb516656; // Granular Guardian
  }

  function aDIContractsToUpdate() public pure override returns (address[] memory) {
    address[] memory contracts = new address[](1);
    contracts[0] = 0xD92b37a5114b33F668D274Fb48f23b726a854d6E; // CCC
    return contracts;
  }
}

contract Soneium is Script, UpdateCCCPermissionsSoneium {
  function run() external {
    vm.startBroadcast();

    _changeOwnerAndGuardian();

    vm.stopBroadcast();
  }
}

contract UpdateCCCPermissionsBob is UpdateCCCPermissions {
  function targetOwner() public pure override returns (address) {
    return 0x90800d1F54384523723eD3962c7Cd59d7866c83d; // executor
  }

  function targetADIGuardian() public pure override returns (address) {
    return 0xb2C672931Bd1Da226e29997Ec8cEB60Fb1DA3959; // Granular Guardian
  }

  function aDIContractsToUpdate() public pure override returns (address[] memory) {
    address[] memory contracts = new address[](1);
    contracts[0] = 0xf630C8A7bC033FD20fcc45d8B43bFe92dE73154F; // CCC
    return contracts;
  }
}

contract Bob is Script, UpdateCCCPermissionsBob {
  function run() external {
    vm.startBroadcast();

    _changeOwnerAndGuardian();

    vm.stopBroadcast();
  }
}

contract UpdateCCCPermissionsPlasma is UpdateCCCPermissions {
  function targetOwner() public pure override returns (address) {
    return 0x47aAdaAE1F05C978E6aBb7568d11B7F6e0FC4d6A; // executor
  }

  function targetADIGuardian() public pure override returns (address) {
    return 0x60665b4F4FF7073C5fed2656852dCa271DfE2684; // Granular Guardian
  }

  function aDIContractsToUpdate() public pure override returns (address[] memory) {
    address[] memory contracts = new address[](1);
    contracts[0] = 0x643441742f73e270e565619be6DE5f4D55E08cd6; // CCC
    return contracts;
  }
}

contract Plasma is Script, UpdateCCCPermissionsPlasma {
  function run() external {
    vm.startBroadcast();

    _changeOwnerAndGuardian();

    vm.stopBroadcast();
  }
}

contract UpdateCCCPermissionsXlayer is UpdateCCCPermissions {
  function targetOwner() public pure override returns (address) {
    return 0xE2E8Badc5d50f8a6188577B89f50701cDE2D4e19; // executor
  }

  function targetADIGuardian() public pure override returns (address) {
    return 0xD6727ec503A8d0C10a0EAA4e76eAf9A628188b25; // Granular Guardian
  }

  function aDIContractsToUpdate() public pure override returns (address[] memory) {
    address[] memory contracts = new address[](1);
    contracts[0] = 0xFdd46155fD3DA5B907AD3B9f9395366290f58097; // CCC
    return contracts;
  }
}

contract Xlayer is Script, UpdateCCCPermissionsXlayer {
  function run() external {
    vm.startBroadcast();

    _changeOwnerAndGuardian();

    vm.stopBroadcast();
  }
}

contract UpdateCCCPermissionsMegaeth is UpdateCCCPermissions {
  function targetOwner() public pure override returns (address) {
    return 0xE2E8Badc5d50f8a6188577B89f50701cDE2D4e19; // executor
  }

  function targetADIGuardian() public pure override returns (address) {
    return 0x8Fa22D09b13486A40cd6b04398b948AA8bD5853A; // Granular Guardian
  }

  function aDIContractsToUpdate() public pure override returns (address[] memory) {
    address[] memory contracts = new address[](1);
    contracts[0] = 0x5EE63ACb37AeCDc7e23ACA283098f8ffD9677BBe; // CCC
    return contracts;
  }
}

contract Megaeth is Script, UpdateCCCPermissionsMegaeth {
  function run() external {
    vm.startBroadcast();

    _changeOwnerAndGuardian();

    vm.stopBroadcast();
  }
}

contract UpdateCCCPermissionsMonad is UpdateCCCPermissions {
  function targetOwner() public pure override returns (address) {
    return 0xa9d0EAFF48cE1DF468f9eAeb7e628c413343F6A2; // executor
  }

  function targetADIGuardian() public pure override returns (address) {
    return 0xD3DD0bE957fcE2dCd359e09374Cbc99f60337D42; // Granular Guardian
  }

  function aDIContractsToUpdate() public pure override returns (address[] memory) {
    address[] memory contracts = new address[](1);
    contracts[0] = 0x8dd5b84b26ae3916A5Fb34C8968F93d206216b63; // CCC
    return contracts;
  }
}

contract Monad is Script, UpdateCCCPermissionsMonad {
  function run() external {
    vm.startBroadcast();

    _changeOwnerAndGuardian();

    vm.stopBroadcast();
  }
}

/// @dev the CCC and Granular Guardian are read from deployments/tempo.json
contract UpdateCCCPermissionsTempo is Script, UpdateCCCPermissions {
  function _tempoAddresses() internal view returns (Addresses memory) {
    return DeployerHelpers.decodeJson(DeployerHelpers.getPathByChainId(ChainIds.TEMPO), vm);
  }

  function targetOwner() public pure override returns (address) {
    return 0x502fDdcC5586cf94BD0D313798f2006984D53DAF; // executor
  }

  function targetADIGuardian() public view override returns (address) {
    return _tempoAddresses().granularCCCGuardian;
  }

  function aDIContractsToUpdate() public view override returns (address[] memory) {
    address[] memory contracts = new address[](1);
    contracts[0] = _tempoAddresses().crossChainController;
    return contracts;
  }
}

contract Tempo is UpdateCCCPermissionsTempo {
  function run() external {
    vm.startBroadcast();

    _changeOwnerAndGuardian();

    vm.stopBroadcast();
  }
}
