# a.DI Deploy

This repository has the scripts necessary to deploy a.DI on all networks supported by Aave.

It also hosts the necessary scripts and payloads for a.DI maintenance

## Deployments

[This](/deployments) directory contains the current deployed addresses for the different supported networks.

## Diffs

[This](/diffs) directory contains the generated diffs for the different payloads. Comparing current state with the state after payload execution.

## Scripts

[This](scripts) directory contains the necessary scripts to deploy a.DI on a network. It also has the specific scripts to
deploy payloads

## Src

[This](src) directory contains the source code of specific payloads. a.DI code is imported from the [aave-delivery-infrastructure](https://github.com/bgd-labs/aave-delivery-infrastructure) repository.

Here it can also be found some helper templates to use when creating payloads. For example, to add a new bridge adapter or to update CrossChainController implementation.

## Tests

[This](tests) directory contains the tests for the payloads. To generate the diffs, inherit from [ADITestBase.sol](/tests/adi/ADITestBase.sol) and call `defaultTest` method.

## License

Copyright © 2025, Aave DAO, represented by its governance smart contracts.

Created by [BGD Labs](https://bgdlabs.com/).

The default license of this repository is [BUSL1.1](./LICENSE).

**IMPORTANT**. The BUSL1.1 license of this repository allows for any usage of the software, if respecting the *Additional Use Grant* limitations, forbidding any use case damaging anyhow the Aave DAO's interests.

