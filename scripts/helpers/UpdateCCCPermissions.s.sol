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



contract UpdateCCCPermissionsCelo is UpdateCCCPermissions {
  function targetOwner() public pure override returns (address) {
    return 0x1dF462e2712496373A347f8ad10802a5E95f053D;
  }

  function targetADIGuardian() public pure override returns (address) {
    return 0xbE815420A63A413BB8D508d8022C0FF150Ea7C39; // Granular Guardian
  }


  function aDIContractsToUpdate() public pure override returns (address[] memory) {
    address[] memory contracts = new address[](1);
    contracts[0] = 0x50F4dAA86F3c747ce15C3C38bD0383200B61d6Dd;
    return contracts;
  }
}

contract Celo is Script, UpdateCCCPermissionsCelo {
  function run() external {
    vm.startBroadcast();
    
    _changeOwnerAndGuardian();
    
    vm.stopBroadcast();
  }
}