// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import {OwnableWithGuardian, IWithGuardian} from 'solidity-utils/contracts/access-control/OwnableWithGuardian.sol';

abstract contract UpdateCCCPermissions {
  function targetOwner() public pure virtual returns (address);

  function targetADIGuardian() public pure virtual returns (address);

  function aDIContractsToUpdate() public pure virtual returns (address[] memory);

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
    return 0x47aAdaAE1F05C978E6aBb7568d11B7F6e0FC4d6A; // executor
  }

  function targetADIGuardian() public pure override returns (address) {
    return 0x80235F027952d69121d3FCa0b996708AC5aDCB5B; // Granular Guardian
  }

  function aDIContractsToUpdate() public pure override returns (address[] memory) {
    address[] memory contracts = new address[](1);
    contracts[0] = 0xef59a4eF559Bc7DA51B4A11E8cE24fC8bA0a8561; // CCC
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