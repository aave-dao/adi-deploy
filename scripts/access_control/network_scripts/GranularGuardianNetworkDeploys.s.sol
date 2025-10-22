// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {GovernanceV3Ethereum} from 'aave-address-book/GovernanceV3Ethereum.sol';
import {GovernanceV3Polygon} from 'aave-address-book/GovernanceV3Polygon.sol';
import {GovernanceV3Avalanche} from 'aave-address-book/GovernanceV3Avalanche.sol';
import {GovernanceV3BNB} from 'aave-address-book/GovernanceV3BNB.sol';
import {GovernanceV3Gnosis} from 'aave-address-book/GovernanceV3Gnosis.sol';
import {GovernanceV3Arbitrum} from 'aave-address-book/GovernanceV3Arbitrum.sol';
import {GovernanceV3Optimism} from 'aave-address-book/GovernanceV3Optimism.sol';
import {GovernanceV3Base} from 'aave-address-book/GovernanceV3Base.sol';
import {GovernanceV3Scroll} from 'aave-address-book/GovernanceV3Scroll.sol';
import {GovernanceV3Metis} from 'aave-address-book/GovernanceV3Metis.sol';
import {MiscPolygon} from 'aave-address-book/MiscPolygon.sol';
import {MiscAvalanche} from 'aave-address-book/MiscAvalanche.sol';
import {MiscBNB} from 'aave-address-book/MiscBNB.sol';
import {MiscGnosis} from 'aave-address-book/MiscGnosis.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {MiscArbitrum} from 'aave-address-book/MiscArbitrum.sol';
import {MiscOptimism} from 'aave-address-book/MiscOptimism.sol';
import {MiscBase} from 'aave-address-book/MiscBase.sol';
import {MiscScroll} from 'aave-address-book/MiscScroll.sol';
import {MiscMetis} from 'aave-address-book/MiscMetis.sol';
import '../DeployGranularGuardian.s.sol';

contract Ethereum is DeployGranularGuardian {
  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function DEFAULT_ADMIN() internal pure override returns (address) {
    return GovernanceV3Ethereum.EXECUTOR_LVL_1;
  }

  function RETRY_GUARDIAN() internal pure override returns (address) {
    return 0xb812d0944f8F581DfAA3a93Dda0d22EcEf51A9CF; // bgd guardian
  }

  function SOLVE_EMERGENCY_GUARDIAN() internal pure override returns (address) {
    return 0xCe52ab41C40575B072A18C9700091Ccbe4A06710;
  }
}

contract Avalanche is DeployGranularGuardian {
  function DEFAULT_ADMIN() internal pure override returns (address) {
    return GovernanceV3Avalanche.EXECUTOR_LVL_1;
  }

  function RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x3DBA1c4094BC0eE4772A05180B7E0c2F1cFD9c36; // bgd guardian
  }

  function SOLVE_EMERGENCY_GUARDIAN() internal pure override returns (address) {
    return 0x360c0a69Ed2912351227a0b745f890CB2eBDbcFe;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.AVALANCHE;
  }
}

contract Polygon is DeployGranularGuardian {
  function DEFAULT_ADMIN() internal pure override returns (address) {
    return GovernanceV3Polygon.EXECUTOR_LVL_1;
  }

  function RETRY_GUARDIAN() internal pure override returns (address) {
    return 0xbCEB4f363f2666E2E8E430806F37e97C405c130b; // bgd guardian
  }

  function SOLVE_EMERGENCY_GUARDIAN() internal pure override returns (address) {
    return 0x1A0581dd5C7C3DA4Ba1CDa7e0BcA7286afc4973b;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.POLYGON;
  }
}

contract Binance is DeployGranularGuardian {
  function DEFAULT_ADMIN() internal pure override returns (address) {
    return GovernanceV3BNB.EXECUTOR_LVL_1;
  }

  function RETRY_GUARDIAN() internal pure override returns (address) {
    return 0xE8C5ab722d0b1B7316Cc4034f2BE91A5B1d29964; // bgd guardian
  }

  function SOLVE_EMERGENCY_GUARDIAN() internal pure override returns (address) {
    return 0x1A0581dd5C7C3DA4Ba1CDa7e0BcA7286afc4973b;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.BNB;
  }
}

contract Gnosis is DeployGranularGuardian {
  function DEFAULT_ADMIN() internal pure override returns (address) {
    return GovernanceV3Gnosis.EXECUTOR_LVL_1;
  }

  function RETRY_GUARDIAN() internal pure override returns (address) {
    return 0xcb8a3E864D12190eD2b03cbA0833b15f2c314Ed8; // bgd guardian
  }

  function SOLVE_EMERGENCY_GUARDIAN() internal pure override returns (address) {
    return 0x1A0581dd5C7C3DA4Ba1CDa7e0BcA7286afc4973b;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.GNOSIS;
  }
}

contract Metis is DeployGranularGuardian {
  function DEFAULT_ADMIN() internal pure override returns (address) {
    return GovernanceV3Metis.EXECUTOR_LVL_1;
  }

  function RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x9853589F951D724D9f7c6724E0fD63F9d888C429; // bgd guardian
  }

  function SOLVE_EMERGENCY_GUARDIAN() internal pure override returns (address) {
    return 0x360c0a69Ed2912351227a0b745f890CB2eBDbcFe;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.METIS;
  }
}

contract Scroll is DeployGranularGuardian {
  function DEFAULT_ADMIN() internal pure override returns (address) {
    return GovernanceV3Scroll.EXECUTOR_LVL_1;
  }

  function RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x4aAa03F0A61cf93eA252e987b585453578108358; // bgd guardian
  }

  function SOLVE_EMERGENCY_GUARDIAN() internal pure override returns (address) {
    return 0x1A0581dd5C7C3DA4Ba1CDa7e0BcA7286afc4973b;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.SCROLL;
  }
}

contract Optimism is DeployGranularGuardian {
  function DEFAULT_ADMIN() internal pure override returns (address) {
    return GovernanceV3Optimism.EXECUTOR_LVL_1;
  }

  function RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x3A800fbDeAC82a4d9c68A9FA0a315e095129CDBF; // bgd guardian
  }

  function SOLVE_EMERGENCY_GUARDIAN() internal pure override returns (address) {
    return 0x360c0a69Ed2912351227a0b745f890CB2eBDbcFe;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.OPTIMISM;
  }
}

contract Arbitrum is DeployGranularGuardian {
  function DEFAULT_ADMIN() internal pure override returns (address) {
    return GovernanceV3Arbitrum.EXECUTOR_LVL_1;
  }

  function RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x1Fcd437D8a9a6ea68da858b78b6cf10E8E0bF959; // bgd guardian
  }

  function SOLVE_EMERGENCY_GUARDIAN() internal pure override returns (address) {
    return 0x1A0581dd5C7C3DA4Ba1CDa7e0BcA7286afc4973b;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ARBITRUM;
  }
}

contract Base is DeployGranularGuardian {
  function DEFAULT_ADMIN() internal pure override returns (address) {
    return GovernanceV3Base.EXECUTOR_LVL_1;
  }

  function RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x7FDA7C3528ad8f05e62148a700D456898b55f8d2; // bgd guardian
  }

  function SOLVE_EMERGENCY_GUARDIAN() internal pure override returns (address) {
    return 0x360c0a69Ed2912351227a0b745f890CB2eBDbcFe;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.BASE;
  }
}

contract Zksync is DeployGranularGuardian {
  function DEFAULT_ADMIN() internal pure override returns (address) {
    return 0x04cE39789e11a49595cD0ECEf6f4Bd54ABF4d020; //GovernanceV3Zksync.EXECUTOR_LVL_1;
  }

  function RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x2451337aD5fE8b563bEB3b9c4A2B8789294879Ec; //  bgd guardian
  }

  function SOLVE_EMERGENCY_GUARDIAN() internal pure override returns (address) {
    return 0x4257bf0746D783f0D962913d7d8AFA408B62547E;
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.ZKSYNC;
  }
}

contract Linea is DeployGranularGuardian {
  function DEFAULT_ADMIN() internal pure override returns (address) {
    return 0x8c2d95FE7aeB57b86961F3abB296A54f0ADb7F88; //GovernanceV3Linea.EXECUTOR_LVL_1;
  }

  function RETRY_GUARDIAN() internal pure override returns (address) {
    return 0xfD3a6E65e470a7D7D730FFD5D36a9354E8F9F4Ea; //  bgd guardian
  }

  function SOLVE_EMERGENCY_GUARDIAN() internal pure override returns (address) {
    return 0x056E4C4E80D1D14a637ccbD0412CDAAEc5B51F4E; // dao governance guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.LINEA;
  }
}

contract Celo is DeployGranularGuardian {
  function DEFAULT_ADMIN() internal pure override returns (address) {
    return 0x1dF462e2712496373A347f8ad10802a5E95f053D; //GovernanceV3Celo.EXECUTOR_LVL_1;
  }

  function RETRY_GUARDIAN() internal pure override returns (address) {
    return 0xfD3a6E65e470a7D7D730FFD5D36a9354E8F9F4Ea; //  bgd guardian
  }

  function SOLVE_EMERGENCY_GUARDIAN() internal pure override returns (address) {
    return 0x056E4C4E80D1D14a637ccbD0412CDAAEc5B51F4E; // dao governance guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.CELO;
  }
}

contract Sonic is DeployGranularGuardian {
  function DEFAULT_ADMIN() internal pure override returns (address) {
    return 0x7b62461a3570c6AC8a9f8330421576e417B71EE7; //GovernanceV3Sonic.EXECUTOR_LVL_1;
  }

  function RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x7837d7a167732aE41627A3B829871d9e32e2e7f2; //  bgd guardian
  }

  function SOLVE_EMERGENCY_GUARDIAN() internal pure override returns (address) {
    return 0x63C4422D6cc849549daeb600B7EcE52bD18fAd7f; // dao governance guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.SONIC;
  }
}

contract Mantle is DeployGranularGuardian {
  function DEFAULT_ADMIN() internal pure override returns (address) {
    return 0x70884634D0098782592111A2A6B8d223be31CB7b; //GovernanceV3Mantle.EXECUTOR_LVL_1;
  }

  function RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x0686f59Cc2aEc1ccf891472Dc6C89bB747F6a4A7; //  bgd guardian
  }

  function SOLVE_EMERGENCY_GUARDIAN() internal pure override returns (address) {
    return 0x14816fC7f443A9C834d30eeA64daD20C4f56fBCD; // dao governance guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.MANTLE;
  }
}

contract Ink is DeployGranularGuardian {
  function DEFAULT_ADMIN() internal pure override returns (address) {
    return 0x47aAdaAE1F05C978E6aBb7568d11B7F6e0FC4d6A; //GovernanceV3Ink.EXECUTOR_LVL_1;
  }

  function RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x81D251dA015A0C7bD882918Ca1ec6B7B8E094585; //  bgd guardian
  }

  function SOLVE_EMERGENCY_GUARDIAN() internal pure override returns (address) {
    return 0x1bBcC6F0BB563067Ca45450023a13E34fa963Fa9; // dao governance guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.INK;
  }
}

contract Soneium is DeployGranularGuardian {
  function DEFAULT_ADMIN() internal pure override returns (address) {
    return 0x47aAdaAE1F05C978E6aBb7568d11B7F6e0FC4d6A; //GovernanceV3Soneium.EXECUTOR_LVL_1;
  }

  function RETRY_GUARDIAN() internal pure override returns (address) {
    return 0xdc62E0e65b2251Dc66404ca717FD32dcC365Be3A; //  bgd guardian
  }

  function SOLVE_EMERGENCY_GUARDIAN() internal pure override returns (address) {
    return 0x19CE4363FEA478Aa04B9EA2937cc5A2cbcD44be6; // dao governance guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.SONEIUM;
  }
}

contract Bob is DeployGranularGuardian {
  function DEFAULT_ADMIN() internal pure override returns (address) {
    return 0x90800d1F54384523723eD3962c7Cd59d7866c83d; //GovernanceV3Bob.EXECUTOR_LVL_1;
  }

  function RETRY_GUARDIAN() internal pure override returns (address) {
    return 0xdc62E0e65b2251Dc66404ca717FD32dcC365Be3A; //  bgd guardian
  }

  function SOLVE_EMERGENCY_GUARDIAN() internal pure override returns (address) {
    return 0x19CE4363FEA478Aa04B9EA2937cc5A2cbcD44be6; // dao governance guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.BOB;
  }
}

contract Plasma is DeployGranularGuardian {
  function DEFAULT_ADMIN() internal pure override returns (address) {
    return 0x47aAdaAE1F05C978E6aBb7568d11B7F6e0FC4d6A; //GovernanceV3Plasma.EXECUTOR_LVL_1;
  }

  function RETRY_GUARDIAN() internal pure override returns (address) {
    return 0xdc62E0e65b2251Dc66404ca717FD32dcC365Be3A; //  bgd guardian
  }

  function SOLVE_EMERGENCY_GUARDIAN() internal pure override returns (address) {
    return 0x19CE4363FEA478Aa04B9EA2937cc5A2cbcD44be6; // dao governance guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.PLASMA;
  }
}

contract Xlayer is DeployGranularGuardian {
  function DEFAULT_ADMIN() internal pure override returns (address) {
    return address(0); //GovernanceV3XLayer.EXECUTOR_LVL_1;
  }

  function RETRY_GUARDIAN() internal pure override returns (address) {
    return 0x734c3fF8DE95c3745770df69053A31FDC92F2526; //  bgd guardian
  }

  function SOLVE_EMERGENCY_GUARDIAN() internal pure override returns (address) {
    return 0xeB55A63bf9993d80c86D47f819B5eC958c7C127B; // dao governance guardian
  }

  function TRANSACTION_NETWORK() internal pure override returns (uint256) {
    return ChainIds.XLAYER;
  }
}
