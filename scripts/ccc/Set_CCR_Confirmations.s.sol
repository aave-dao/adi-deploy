// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {CrossChainController, ICrossChainController} from 'adi/CrossChainController.sol';
import {ICrossChainReceiver} from 'adi/interfaces/ICrossChainReceiver.sol';
import '../BaseDeployerScript.sol';

abstract contract BaseSetCCRConfirmations is BaseDeployerScript {
  struct ConfirmationsByChain {
    uint8 confirmations;
    uint256 chainId;
  }

  function getConfirmationsByChainIds() public virtual returns (ConfirmationsByChain[] memory);

  function _execute(Addresses memory addresses) internal override {
    ConfirmationsByChain[] memory confirmationsByChain = getConfirmationsByChainIds();
    ICrossChainReceiver.ConfirmationInput[]
      memory confirmationsInput = new ICrossChainReceiver.ConfirmationInput[](
        confirmationsByChain.length
      );

    for (uint256 i = 0; i < confirmationsByChain.length; i++) {
      confirmationsInput[i] = ICrossChainReceiver.ConfirmationInput({
        chainId: confirmationsByChain[i].chainId,
        requiredConfirmations: confirmationsByChain[i].confirmations
      });
    }

    ICrossChainReceiver(addresses.crossChainController).updateConfirmations(confirmationsInput);
  }
}

contract Ethereum is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](2);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.POLYGON, confirmations: 3});
    chainIds[1] = ConfirmationsByChain({chainId: ChainIds.AVALANCHE, confirmations: 2});

    return chainIds;
  }
}

contract Polygon is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.POLYGON;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 3});

    return chainIds;
  }
}

contract Avalanche is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.AVALANCHE;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 2});

    return chainIds;
  }
}

contract Optimism is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.OPTIMISM;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 1});

    return chainIds;
  }
}

contract Arbitrum is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.ARBITRUM;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 1});

    return chainIds;
  }
}

contract Metis is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.METIS;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 1});

    return chainIds;
  }
}

contract Binance is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.BNB;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 2});

    return chainIds;
  }
}

contract Base is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.BASE;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 1});

    return chainIds;
  }
}

contract Gnosis is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.GNOSIS;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 2});

    return chainIds;
  }
}

contract Scroll is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.SCROLL;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 1});

    return chainIds;
  }
}

contract Celo is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.CELO;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 2});

    return chainIds;
  }
}

contract Zksync is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.ZKSYNC;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 1});

    return chainIds;
  }
}

contract Linea is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.LINEA;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 1});

    return chainIds;
  }
}

contract Mantle is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.MANTLE;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 1});

    return chainIds;
  }
}

contract Sonic is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.SONIC;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 2});

    return chainIds;
  }
}

contract Ink is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.INK;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 1});

    return chainIds;
  }
}

contract Soneium is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.SONEIUM;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 1});

    return chainIds;
  }
}

contract Bob is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.BOB;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 1});

    return chainIds;
  }
}

contract Plasma is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.PLASMA;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 2});

    return chainIds;
  }
}

contract Xlayer is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.XLAYER;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 1});

    return chainIds;
  }
}

contract Megaeth is BaseSetCCRConfirmations {
  function TRANSACTION_NETWORK() internal pure virtual override returns (uint256) {
    return ChainIds.MEGAETH;
  }

  function getConfirmationsByChainIds()
    public
    virtual
    override
    returns (ConfirmationsByChain[] memory)
  {
    ConfirmationsByChain[] memory chainIds = new ConfirmationsByChain[](1);
    chainIds[0] = ConfirmationsByChain({chainId: ChainIds.ETHEREUM, confirmations: 1});

    return chainIds;
  }
}
