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



contract UpdateCCCPermissionsSonic is UpdateCCCPermissions {
  function targetOwner() public pure override returns (address) {
    return 0x7b62461a3570c6AC8a9f8330421576e417B71EE7; // executor
  }

  function targetADIGuardian() public pure override returns (address) {
    return 0x10078c1D8E46dd1ed5D8df2C42d5ABb969b11566; // Granular Guardian
  }


  function aDIContractsToUpdate() public pure override returns (address[] memory) {
    address[] memory contracts = new address[](1);
    contracts[0] = 0x58e003a3C6f2Aeed6a2a6Bc77B504566523cb15c; // CCC
    return contracts;
  }
}

contract Sonic is Script, UpdateCCCPermissionsSonic {
  function run() external {
    vm.startBroadcast();
    
    _changeOwnerAndGuardian();
    
    vm.stopBroadcast();
  }
}