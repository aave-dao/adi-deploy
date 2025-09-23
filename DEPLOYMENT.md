
# Deployment of the Aave Delivery Infrastructure contracts

This document outlines deployment steps for various parts of the Aave Delivery Infrastructure (aDI).
All of these scripts inherit from base scripts in the [Aave Delivery Infrastructure](https://github.com/aave-dao/aave-delivery-infrastructure) repository. An explanation on how they work can be found [here](https://github.com/aave-dao/aave-delivery-infrastructure/blob/main/scripts/README.md).

# aDI Deployment Order

## Prerequisites
1. [Setup Environment](./DEPLOYMENT.md#setup) - Configure `.env`, `foundry.toml`, and scripts
2. [Initial Scripts](./DEPLOYMENT.md#initial-scripts) - Generate network address JSON files
   
## Core Infrastructure Deployment

3. [Emergency Registry](./DEPLOYMENT.md#emergency) - Deploy on Ethereum (central hub)
4. [CrossChainController (CCC)](./DEPLOYMENT.md#ccc) - Deploy on all target networks
5. [Access Control](./DEPLOYMENT.md#access-control) - Deploy Granular Guardian (requires CCC)
   
## Network Connectivity
6. [Adapters](./DEPLOYMENT.md#adapters) - Deploy bridge adapters (requires CCC)
   
## Configuration
7. [CCC Configuration](./DEPLOYMENT.md#ccc) - Configure cross-chain communications

## Post Deployment
- [Permissions Transfer](./DEPLOYMENT.md#helpers) - Transfer ownership from deployer to proper governance
- [Pre-Production Testing](./DEPLOYMENT.md#pre-production) - Test with mock destinations

## Maintanance 

This repository also contains scripts for deploying payloads to maintain and update the aDI system:
- [Payloads](./DEPLOYMENT.md#payloads)


# Setup

Several configuration items require updates or modifications for deployments across different networks:

- *.env*: copy [.env.example](./.env.example) to a `.env` file, and populate it. Use `MNEMONIC_INDEX` and `LEDGER_SENDER` for manual wallet confirmation, or include the private key if you want an automated deployment (instructions for choosing between deployment methods are provided later)
- *[foundry.toml](./foundry.toml)*: when adding a new network, include the respective definitions (`rpc_endpoints` and `etherscan`). Add network configuration to the `etherscan` section only if the network isn't supported by Etherscan. For networks requiring special configuration, add them under the network profile section.
- *scripts*: the deployment scripts for the different parts of the system are located in the [scripts](./scripts/) folder.
If you are adding a new network, first verify that the network exists in the [Solidity Utils](https://github.com/bgd-labs/solidity-utils/blob/main/src/contracts/utils/ChainHelpers.sol) repository, then add a new network script to [InitialDeployment.s.sol](). The deployment scripts retrieve necessary addresses from generated JSON files in the [deployments](./deployments/) folder, so you must follow the strict deployment order, that will be specified later. After deployment, the scripts save the newly deployed addresses to the JSON files.
- *deployments*: The [deployments](./deployments/) folder contains the deployed addresses for every network. Note that the JSON files are modified during execution or simulation. If simulation runs but execution fails, the addresses will still be modified.
- *Makefile*: the [Makefile](./Makefile) contains commands for deploying each smart contract to a selected network. To deploy smart contracts to a new network, first add the necessary network scripts, then change the network name in the relevant command and execute it.
You can deploy using a private key or using a ledger (by adding `LEDGER=true` to the execution command). If you deploy into a mainnet network, add: `PROD=true`. Set the gwei amount for transactions if needed.

Here's an example of the initial command that generates network address JSON files:

```
deploy-initial:
	$(call deploy_fn,InitialDeployments,ethereum polygon avalanche arbitrum optimism metis base binance gnosis)
```
Include only your target network(s) in this command. Multiple networks will deploy sequentially.

Execution command example: `make deploy-initial PROD=true LEDGER=true`

## Notes

- Some contracts require addresses from previously deployed contracts (including those on other networks) for proper communication. Therefore, follow the specified deployment order strictly.

# Initial Scripts

As previously said, add the new network script to `InitialDeployments` and execute the initial script only for a new network (since doing it for existing ones would overwrite the addresses JSON of the specified network with address(0)). The initial script creates a new addresses JSON for the new network.

- execution command: `make deploy-initial PROD=true LEDGER=true` 

# Emergency

An Emergency Registry contract must be deployed on Ethereum (the system's central hub) to signal emergencies across connected networks, enabling authorized entities to implement necessary changes and resolve situations.
Set the OWNER address to let the entity trigger emergencies on selected networks (defaults to msg.sender). This ownership should be assigned to executor level 1 to delegate responsibility to Aave Governance.

Networks requiring emergency resolution need Emergency Oracle deployment. These are typically networks using third-party bridge providers instead of native L2 bridges. The Emergency Oracle is a contract that monitors the Emergency Registry to determine if the current network has an activated emergency flag. The deployment and maintenance of the Emergency Oracle has been delegated to [Chainlink](https://dev.chain.link/).

## Scripts

To deploy the Emergency Registry the following script is needed:

- [DeployEmergencyRegistry.s.sol](./scripts/emergency/DeployEmergencyRegistry.s.sol)

## Makefile

Specify the required networks in the Makefile:

- `make deploy-emergency-registry PROD=true LEDGER=true`: Deploys Emergency Registry.

# CCC

The CrossChainController serves as the central component of aDI, setting adapters and configurations and managing communications.
Depending on the network you will need to pass the EmergencyOracle deployed by Chainlink.

- Approve the address that can initiate message sending to a destination network
- Set adapters in both origin and destination CCCs to enable communication between networks
- Set the number of confirmations to forward received message to a destination contract (this sets the minimum number of adapters needed to receive and validate messages)

## Scripts

To deploy and set the configurations, the following scripts are needed:

- [DeployCCC.s.sol](./scripts/ccc/DeployCCC.s.sol): Deploys CCC. Deploys different implementation contracts depending on whether an EmergencyOracle is passed. Sets executor level 1 as the proxy admin owner.
Move ownership to executor after completing all configurations (defaults to msg.sender). Move Guardian to GranularGuardian after completing all configurations (defaults to msg.sender).
- [Set_CCF_Approved_Senders.s.sol](./scripts/ccc/Set_CCF_Approved_Senders.s.sol): Sets a list of addresses as allowed senders to let them initiate cross-chain messaging.
- [Remove_CCF_Sender_Adapters.s.sol](./scripts/ccc/Remove_CCF_Sender_Adapters.s.sol): Sets a list of origin/destination adapter pairs for specified networks to allow cross-chain message sending.
- [Set_CCR_Receivers_Adapters.s.sol](./scripts/ccc/Set_CCR_Receivers_Adapters.s.sol): Sets a list of receiver adapters to allow cross-chain messaging from origin network.
- [Set_CCR_Confirmations.s.sol](./scripts/ccc/Set_CCR_Confirmations.s.sol): Sets a minimum number of confirmations to mark a message as valid and forward it to the specified address.

## Makefile

Remember to specify the networks needed in the Makefile.

- `make deploy-cross-chain-infra PROD=true LEDGER=true`: deploys CCC
- `make set-approved-ccf-senders PROD=true LEDGER=true`: sets approved senders to CCC
- `make set-ccf-sender-adapters PROD=true LEDGER=true`: sets adapter pairs for specified network paths
- `make set-ccr-receiver-adapters PROD=true LEDGER=true`: sets receiver adapters for specified origin networks
- `make set-ccr-confirmations PROD=true LEDGER=true`: sets confirmations for specified origin networks

# Access Control

The access control scripts consist of deploying the GranularGuardian contract. You need to specify the following roles:

- DEFAULT_ADMIN: This role can set other roles and should be granted to the executor level 1.
- RETRY_GUARDIAN: This role can retry transactions and envelopes. Grant this to an entity with system expertise, typically the BGD guardian.
- SOLVE_EMERGENCY_GUARDIAN: This role can change CCC configuration during emergencies. Grant this to the Aave Governance guardian.

## Scripts

Prerequisites: These scripts require prior Governance (executor) and CCC deployment, since Granular Guardian connects directly to CCC.

To deploy the Granular Guardian correctly, add the network script to:

- [DeployGranularGuardian.s.sol](./scripts/access_control/DeployGranularGuardian.s.sol): Base script that calls the Granular Guardian base deployment script, passing the CCC.
- [GranularGuardianNetworkDeploys.s.sol](./scripts/access_control/network_scripts/GranularGuardianNetworkDeploys.s.sol): Script file where network scripts are added. Define the addresses for the different roles here.

## Makefile

Specify the required networks in the Makefile.

- `make deploy_ccc_granular_guardian PROD=true LEDGER=true`: deploy Granular Guardian.

# Adapters

There is one Adapter script per bridge provider integration. L2 networks use native network adapters for network-native bridging, while other networks use third-party bridge providers (CCIP, LZ, HL, Wormhole) that can serve multiple networks simultaneously. For these providers, ensure the bridging path is supported by the provider and configured on the contract side.
Adapters require the origin CCC address to accept messages and the current CCC address to deliver received messages.
Each adapter may need additional configurations, such as the GasLimit for message delivery on the destination network or different bridge provider addresses for provider communication.

## Setters

Once adapters are deployed, they need to be set on both sides of the path, so that the networks are correctly connected.
- To send messages, configure the origin/destination adapter pairs so CCC knows where to send messages.
- To receive messages, set the receiver adapters (which need the origin CCC to verify that messages have the correct origin).

## Scripts

The scripts to deploy the bridge adapters, and set them on CCC are located here:
(The adapters depend on having deployed CCC in current and origin chain beforehand).

- [Adapters](./scripts/adapters/): folder containing adapter deploying scripts.
- [Set_CCF_Sender_Adapters.s.sol](./scripts/ccc/Set_CCF_Sender_Adapters.s.sol): Script that configures origin/destination adapter pairs, enabling message sending from origin to a destination network.
- [Set_CCR_Receivers_Adapters.s.sol](./scripts/ccc/Set_CCR_Receivers_Adapters.s.sol): Script that configures receiver adapters. These adapters need the correct origin CCC to enable message reception from a specified network.

## Makefile

Specify the required networks in the Makefile.

- `make deploy-optimism-adapters PROD=true LEDGER=true`: deploy optimism bridge adapter (There is one make command for each adapter).
- `make set-ccf-sender-adapters PROD=true LEDGER=true`: set sender adapters. Currently adapters only need to be set on Ethereum and voting chains.
- `make set-ccr-receiver-adapters PROD=true LEDGER=true`: set receiver adapters. All networks should have them to receive voting results, voting start messages, or payload execution messages.

Remember that the communication between two networks requires deployment on both origin and destination networks.

# Payloads

This repository also contains all necessary tooling for creating and testing payloads that add or upgrade aDI. The correct workflow:

1. Create payloads in this repository
2. Add tests
3. Generate diffs (showing additions and removals)
4. Use the deployed payload address in the Aave Proposals V3 repository

## Templates

There are a few templates which help with the most used cases for aDI updates/new paths. These are used as inheritance, so you only need to pass certain previously deployed addresses:

- [SimpleAddForwarderAdapter](./src/templates/SimpleAddForwarderAdapter.sol): Adds one network-to-network path, by providing the origin CCC, the origin/destination bridge adapter pair.
- [SimpleOneToManyAdapterUpdate](./src/templates/SimpleOneToManyAdapterUpdate.sol): Adds one to many network-to-network paths. by providing a new origin adapter and multiple destinations.
- [SimpleReceiverAdapterUpdate](./src/templates/SimpleReceiverAdapterUpdate.sol): Adds or removes a receiver adapter from a specified CCC.
- [BaseCCCUpdate](./src/templates/BaseCCCUpdate.sol): Updates the CCC implementation, with the specified signature call for initialization.

There are a few base contracts that can be used to create other common use cases.
For complex use cases beyond template inheritance, create custom ones in the src folder. Examples: addition of multiple bridges for one path, specific CCC implementation updates.

## Scripts

Find and create aDI payload deployment scripts in the [payloads](./scripts/payloads/) folder:

- [adapters](./scripts/payloads/adapters/): Contains scripts to deploy or update network-to-network paths. For new networks, only set the path on Ethereum CCC (receivers are configured during the aDI destination deployment). These scripts add origin/destination adapter pairs for the Ethereum network. Update [Network_Deployments](./scripts/payloads/adapters/ethereum/Network_Deployments.s.sol) with the correct script import for each deployment.
- [ccc](./scripts/payloads/ccc/): Contains a script to update CCC implementations. Update [Network_Deployment](./scripts/payloads/ccc/shuffle/Network_Deployments.s.sol) script with the required deployment script import.

## Tests

Create a test for every new payload in the [tests](./tests/payloads/) folder. These tests are based on a [Base test](./tests/adi/ADITestBase.sol) which contains all necessary functionality tests. Inherit from this contract and call `test_defaultTest`.

## Diffs

Calling `test_defaultTest` from the ADITestBase generates diffs in the [diffs](./diffs/) folder. These diffs contain all the new/removed addresses and configurations from the different parts of the aDI system (forwarder adapters, optimal bandwidth, etc).

## Makefile

Specify the required networks in the Makefile.

- `make deploy-new-path-payload PROD=true LEDGER=true`: deploys new path payload.

# Helpers

The [helpers](./scripts/helpers/) folder contains scripts that help with aDI maintenance.

- [UpdateCCCPermissions.s.sol](./scripts/helpers/UpdateCCCPermissions.s.sol): Updates CCC permissions to the previously deployed Granular Guardian. Run this after completing all setup.

# Pre Production

To test new paths, deploy on the new network mainnet first (instead of testnet). After deployment, send a cross-chain message that executes on a mock destination. This test verifies that all configured adapters work correctly. Once cross-chain message delivery is validated, proceed to production deployment (change the JSON file to `pre-prod-<network>` before production deployment)


- `make deploy_mock_destination PROD=true LEDGER=true`: deploys new mock destination to test cross-chain messaging. (Add network script to [Deploy_Mock_destination](./scripts/helpers/Deploy_Mock_destination.s.sol))
- `make send-direct-message PROD=true LEDGER=true`: sends a message from Ethereum CCC to the specified destination. (Update the destination network in [Send_Direct_CCMessage](./scripts/helpers/Send_Direct_CCMessage.s.sol)).
