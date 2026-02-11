# a.DI Deploy

Deployment and maintenance framework for the [Aave Delivery Infrastructure](https://github.com/bgd-labs/aave-delivery-infrastructure) (a.DI) — the cross-chain communication layer that powers Aave governance across 20+ networks.

This repository contains:
- **Deployment scripts** for all a.DI components (CrossChainController, bridge adapters, access control)
- **Governance payloads** to add new bridge paths and update configurations
- **Payload templates** for common operations (add forwarder, update receiver, upgrade CCC)
- **Testing infrastructure** with automatic before/after diff generation

## Quick Start

```bash
# Install dependencies
forge install && npm install

# Build
make build

# Run tests
make test
```

For the full deployment guide, see [DEPLOYMENT.md](./DEPLOYMENT.md).

## Repository Structure

### [scripts/](./scripts/)

Foundry deployment scripts for all a.DI components:

| Directory | Description |
|-----------|-------------|
| [scripts/InitialDeployments.s.sol](./scripts/InitialDeployments.s.sol) | Proxy factory and initial address JSON generation |
| [scripts/ccc/](./scripts/ccc/) | CrossChainController deployment and configuration (sender adapters, receiver adapters, confirmations) |
| [scripts/adapters/](./scripts/adapters/) | Bridge adapter deployment — one script per provider (CCIP, LayerZero, Hyperlane, Wormhole, and native L2 bridges) |
| [scripts/access_control/](./scripts/access_control/) | GranularGuardian deployment with role-based access control |
| [scripts/payloads/](./scripts/payloads/) | Governance payload deployment scripts |
| [scripts/helpers/](./scripts/helpers/) | Maintenance utilities (permission transfers, test messaging, mock destinations) |

### [src/](./src/)

Solidity source code for payloads and reusable templates:

| File | Description |
|------|-------------|
| [templates/SimpleAddForwarderAdapter.sol](./src/templates/SimpleAddForwarderAdapter.sol) | Add a single network-to-network bridge path |
| [templates/SimpleOneToManyAdapterUpdate.sol](./src/templates/SimpleOneToManyAdapterUpdate.sol) | Add one-to-many bridge paths with a single adapter |
| [templates/SimpleReceiverAdapterUpdate.sol](./src/templates/SimpleReceiverAdapterUpdate.sol) | Add or replace a receiver adapter |
| [templates/BaseCCCUpdate.sol](./src/templates/BaseCCCUpdate.sol) | Upgrade the CrossChainController implementation |
| [templates/BaseAdaptersUpdate.sol](./src/templates/BaseAdaptersUpdate.sol) | Base contract for combined receiver + forwarder updates |
| [adapter_payloads/](./src/adapter_payloads/) | Custom payloads for complex multi-bridge paths |

### [tests/](./tests/)

Payload tests with automatic diff generation. Inherit from [ADITestBase.sol](./tests/adi/ADITestBase.sol) and call `defaultTest` to snapshot CCC state before and after payload execution.

### [deployments/](./deployments/)

JSON files containing deployed contract addresses per network. These are read and updated automatically by the deployment scripts.

### [diffs/](./diffs/)

Generated markdown diffs showing configuration changes introduced by each payload (forwarder adapters, receiver adapters, optimal bandwidth, confirmations).

## Deployment

See [DEPLOYMENT.md](./DEPLOYMENT.md) for:
- Requirements and environment setup
- Full deployment order (initial setup → CCC → adapters → configuration → access control)
- Bridge adapter reference (all Makefile commands)
- Payload creation workflow with template examples
- Pre-production testing process
- Step-by-step guide for adding a new network

## License

Copyright © 2025, Aave DAO, represented by its governance smart contracts.

Created by [BGD Labs](https://bgdlabs.com/).

The default license of this repository is [BUSL1.1](./LICENSE).

**IMPORTANT**. The BUSL1.1 license of this repository allows for any usage of the software, if respecting the *Additional Use Grant* limitations, forbidding any use case damaging anyhow the Aave DAO's interests.

