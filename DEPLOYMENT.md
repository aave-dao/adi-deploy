# Deployment of the Aave Delivery Infrastructure contracts

This document outlines deployment steps for various parts of the Aave Delivery Infrastructure (aDI), consisting of:

- [Emergency](./DEPLOYMENT.md#emergency)
- [CCC](./DEPLOYMENT.md#ccc)
- [Access Control](./DEPLOYMENT.md#access-control)
- [Adapters](./DEPLOYMENT.md#adapters)

All of these scripts inherit from base scripts in the [Aave Delivery Infrastucture](https://github.com/aave-dao/aave-delivery-infrastructure) repository. An explanation on how they work can be found [here](https://github.com/aave-dao/aave-delivery-infrastructure/blob/main/scripts/README.md).

This repository also contains scripts for deploying payloads to maintain and update the aDI system:

- [Payloads](./DEPLOYMENT.md#payloads)


## Setup

Several configuration items require updates or modifications for deployments across different networks:

- *.env*: copy [.env.example](./.env.example) to a `.env` file, and populate it. Use `MNEMONIC_INDEX` and `LEDGER_SENDER` for manual wallet confirmation, or include the private key if you want an automated deployment (instructions for choosing between deployment methods are provided later)
- *[foundry.toml](./foundry.toml)*: when adding a new network, include the respective definitions (`rpc_endpoints` and `etherscan`). Add network configuration to the `etherscan` section only if the network isn't supported by Etherscan. For networks requiring special configuration, add them under the network profile section.
- *scripts*: the deployment scripts for the different parts of the system are located in the [scripts](./scripts/) folder.
If you are adding a new network, first verify that the network exists in the [Solidity Utils](https://github.com/bgd-labs/solidity-utils/blob/main/src/contracts/utils/ChainHelpers.sol) repository, then add a new network script to [InitialDeployment.s.sol](). The deployment scripts retrieve necessary addresses from generated JSON files in the [deployments](./deployments/) folder, so you must follow the strict deployment order, that will be specified later. After deployment, the scripts save the newly deployed addresses to the JSON files.
- *deployments*: The [deployments](./deployments/) folder contains the deployed addresses for every network. Note that the JSON files are modified during execution or simulation. If simulation runs but execution fails, the addresses will still be modified.
- *Makefile*: the [here](./Makefile) contains commands for deploying each smart contract to a selected network. To deploy smart contracts to a new network, first add the necessary network scripts, then change the network name in the relevant command and execute it.
You can deploy using a private key or using a ledger (by adding `LEDGER=true` to the execution command). If you deploy into a mainnet network, add: `PROD=true`. Set the gwei amount for transactions if needed.

Here's an example of the initial command that generates network address JSON files:

```
deploy-initial:
	$(call deploy_fn,InitialDeployments,ethereum polygon avalanche arbitrum optimism metis base binance gnosis)
```
Include only your target network(s) in this command. Multiple networks will deploy sequentially.

Execution command example: `make deploy-initial PROD=true LEDGER=true`

### Notes

- Some contracts require addresses from previously deployed contracts (including those on other networks) for proper communication. Therefore, follow the specified deployment order strictly.

## Initial Scripts

As previously said, add the new network script to `InitialDeployments` and execute the initial script only for a new network (since doing it for existing ones would overwrite the addresses JSON of the specified network with address(0)). The initial script creates a new addresses JSON for the new network.

- execution command: `make deploy-initial PROD=true LEDGER=true` 

## Emergency

An Emergency Registry contract must be deployed on Ethereum (the system's central hub) to signal emergencies across connected networks, enabling authorized entities to implement necessary changes and resolve situations.
You can set the OWNER address, which is the one that will be able to set the emergencies on the selected networks (defaults to msg.sender), should be given to executor lvl 1 to delegate the responsibility to the Aave Governance.

On all the necessary networks (that need Emergency solving), normally determined by the networks that use 3rd party bridge providers (instead of native (L2) bridges), an Emergency Oracle needs to be deployed (Contract that will check Emergency Registry to determine if current network has emergency flag activated). The deployment and maintenance of the Emergency Oracle has been delegated to [Chainlink](https://dev.chain.link/)

### Scripts

To deploy the Emergency Registry the following script is needed:

- [DeployEmergencyRegistry.s.sol](./scripts/emergency/DeployEmergencyRegistry.s.sol)

### Makefile

Remember to specify the networks needed on the Makefile.

- `make deploy-emergency-registry PROD=true LEDGER=true`: Deploys emergency registry.

## CCC

The CrossChainController is the central part of aDI. It is where all the adapters and configurations will be set, and where all communications are managed. 
Depending on the network you will need to pass the EmergencyOracle deployed by Chainlink.

To be able to send a message to a destination network, the address initiating the process needs to be approved beforehand.
To enable communication between two networks, adapters need to be set in origin and destination CCCs.
To enable passing a message received to the specified destination contract, a number of confirmations needs to be set (which effectively sets the minimum number of adapters needed to receive / validate a message).

### Scripts

To deploy and set the configurations, the following scripts are needed:

- [DeployCCC.s.sol](./scripts/ccc/DeployCCC.s.sol): Deploys CCC. Depending on if you pass an EmergencyOracle or not it will deploy different implementation contract. Sets executor lvl 1 as the owner of the proxy admin. Ownership should be moved to executor once all configurations are done (as by default it sets it to msg.sender). Guardian should be moved to GranularGuardian once all the configurations are done (as by default it sets it to msg.sender).
- [Set_CCF_Approved_Senders.s.sol](./scripts/ccc/Set_CCF_Approved_Senders.s.sol): Sets a list of addresses as allowed senders (meaning that those addresses will be able to initiate cross-chain messaging)
- [Remove_CCF_Sender_Adapters.s.sol](./scripts/ccc/Remove_CCF_Sender_Adapters.s.sol): Sets a list of pairs origin / destination adapters for specified networks, allowing cross-chain sending of messages.
- [Set_CCR_Receivers_Adapters.s.sol](./scripts/ccc/Set_CCR_Receivers_Adapters.s.sol): Sets a list of receiver adapters, allowing the cross-chain messaging from origin network.
- [Set_CCR_Confirmations.s.sol](./scripts/ccc/Set_CCR_Confirmations.s.sol): Sets a minimum number of confirmations to mark a message as valid and forward it to the specified address.

### Makefile

Remember to specify the networks needed on the Makefile.

- `make deploy-cross-chain-infra PROD=true LEDGER=true`: deploys CCC
- `make set-approved-ccf-senders PROD=true LEDGER=true`: sets approved senders to CCC
- `make set-ccf-sender-adapters PROD=true LEDGER=true`: sets adapter pairs for specified network paths
- `make set-ccr-receiver-adapters PROD=true LEDGER=true`: sets receiver adapters for specified origin networks
- `make set-ccr-confirmations PROD=true LEDGER=true`: sets confirmations for specified origin networks

## Access Control

The access control scripts consists on deploying the GranularGuardian contract. For this you will need to specify:

- DEFAULT_ADMIN: This role can set other roles, so should be granted to the executor lvl 1.
- RETRY_GUARDIAN: This role can retry transactions and envelopes. Should be granted to entity with expertise of the system. Normally granted to BGD guardian.
- SOLVE_EMERGENCY_GUARDIAN: This role can change ccc configuration on emergency. Should be granted to the Aave Governance guardian.

### Scripts

To correctly deploy the Granular Guardian you will need to add the network script to:
(These scripts depend on Governance (executor) to be deployed beforehand. It also needs CCC to be deployed, as GG is directly tied with it).

- [DeployGranularGuardian.s.sol](./scripts/access_control/DeployGranularGuardian.s.sol): Base script that calls the granular guardian base deployment script, passing the CCC.
- [GranularGuardianNetworkDeploys.s.sol](./scripts/access_control/network_scripts/GranularGuardianNetworkDeploys.s.sol): Script file where the network scripts are added. Here you need to define the different addresses for the different roles needed.

### Makefile

Remember to specify the networks needed on the Makefile.

- `make deploy_ccc_granular_guardian PROD=true LEDGER=true`: deploy granular guardian.

## Adapters

There is one Adapter script for every bridge provider integration. For L2 there is the native network adapter (which uses the network native bridging), and for other networks, we have 3rd party bridge providers (CCIP, LZ, HL, Wormhole) which can be used for multiple networks at the same time. On these, you will need to make sure the bridging path is supported (by the provider, and configured in the contract side).
It is important to note that the adapters need the origin ccc address to be able to accept messages, and the current CCC address to deliver the messages received.
For every adapter there can be extra configurations needed, like the GasLimit to be paid on message delivery (in destination network), or different addresses of the bridge providers (used for provider communication).

### Setters

Once adapters are deployed, the need to be set on both sides of the path, so that the networks are correctly connected.
- To set the sender adapters, you have to set the pair (origin / destination) adapters, so that CCC knows where to send the messages.
- To receive messages, you need to set the receiver adapters (which need the origin CCC to verify that the message has correct origin).

### Scripts

The scripts to deploy the bridge adapters, and set them on CCC are located here:
(The adapters depend on having deployed CCC in current and origin chain beforehand).

- [Adapters](./scripts/adapters/): folder containing the adapter deploying scripts.
- [Set_CCF_Sender_Adapters.s.sol](./scripts/ccc/Set_CCF_Sender_Adapters.s.sol): Script that sets the pair of origin / destination adapters, enabling sending of messages from origin network to destination network.
- [Set_CCR_Receivers_Adapters.s.sol](./scripts/ccc/Set_CCR_Receivers_Adapters.s.sol): Scripts that sets the receiver adapters. These adapters need the correct origin CCC to enable receiving messages from the specified network.

### Makefile

Remember to specify the networks needed on the Makefile.

- `make deploy-optimism-adapters PROD=true LEDGER=true`: deploy optimism bridge adapter (There is one make command for each adapter).
- `make set-ccf-sender-adapters PROD=true LEDGER=true`: set sender adapters. Currently we only need to set adapters on Ethereum, and the voting chains.
- `make set-ccr-receiver-adapters PROD=true LEDGER=true`: set receiver adapters. All networks should have receiver adapters (either to receive voting results, voting start messages, or payload execution messages).

Remember that for communication to work between two networks, you have to deploy the adapter on the origin network and the destination network.

## Payloads

On this repository you can also find all the tooling needed to create and test payloads for adding / upgrading aDI. The correct flow would be to create this payloads in this repository add the tests, create the diffs (which will show additions / removals) and then use the deployed payload address in the Aave Proposals V3 repository.

### Templates

There are a few templates which help with the most used cases for aDI updates / new paths. This are used as inheritance, so that when used you will only need to pass certain previously deployed addresses:

- [SimpleAddForwarderAdapter](./src/templates/SimpleAddForwarderAdapter.sol): Adds one network to network path, by providing the origin CCC, the origin / destination bridge adapter pair.
- [SimpleOneToManyAdapterUpdate](./src/templates/SimpleOneToManyAdapterUpdate.sol): Adds a one to many network to network paths. by providing a new origin adapter and multiple destinations.
- [SimpleReceiverAdapterUpdate](./src/templates/SimpleReceiverAdapterUpdate.sol): Adds or remove a receiver adapter from a specified CCC.
- [BaseCCCUpdate](./src/templates/BaseCCCUpdate.sol): Has the logic to update the CCC implementation, with the specified signature call for initialization.

There are a few base contracts that can be used to create other common use cases as needed.
If the use case is more complex or needs more than just the templates inheritance, it can be created under the src folder. Some examples are addition of multiple bridges for one path, or specific CCC implementation updates.

### Scripts

You can find / create the scripts to deploy the aDI payloads under [payloads](./scripts/payloads/) folder:

- [adapters](./scripts/payloads/adapters/): This folder contains the scripts to deploy / update network to network paths. As for new networks we only need to set the path on Ethereum CCC (as receivers are done on the aDI (destination) deployment stage), this scripts consist only on adding the origin / destination adapter pairs for Ethereum network. For every deployment you will need to update [Network_Deployments](./scripts/payloads/adapters/ethereum/Network_Deployments.s.sol) with the correct script import.
- [ccc](./scripts/payloads/ccc/): This folder contains the script to update CCC implementations. You will need to update the [Network_Deployment](./scripts/payloads/ccc/shuffle/Network_Deployments.s.sol) script with the needed deployment script import.

### Tests

For every new payload you need to create a test under the [tests](./tests/payloads/) folder. These tests are based on a [Base test](./tests/adi/ADITestBase.sol) which contains all the necessary tests to check all the functionality. By inheriting from this contract you then can call the `test_defaultTest`.

### Diffs

By calling `test_defaultTest` from the ADITestBase, diffs will be generated under the [diffs](./diffs/) folder. These diffs will contain all the new / removed addresses and configurations from the different parts of the aDI system (forwarder adapters, optimal bandwidth, etc).

### Makefile

Remember to specify the networks needed on the Makefile.

- `make deploy-new-path-payload PROD=true LEDGER=true`: deploys new path payload.

## Helpers

In [helpers](./scripts/helpers/) you can find other scripts that can help (serve as example) in aDI maintenance.

- [UpdateCCCPermissions.s.sol](./scripts/helpers/UpdateCCCPermissions.s.sol): Script that will update the permissions of CCC to the previously deployed GranularGuardian. (Should be done after everything is set up).

## Pre Production

To test new paths, we deploy on a new network mainnet first (instead of deploying on testnet). Once deployment is done, we send a cross chain message that will execute on a mock destination. This test intends to check that all configured adapters work as intended. Once the cross chain message delivery success is validated, we can proceed to production deployment (do not forget to change the json file to `pre-prod-<network>` before production deployment)


- `make deploy_mock_destination PROD=true LEDGER=true`: deploys new mock destination to test cross chain messaging. (Add network script on [Deploy_Mock_destination](./scripts/helpers/Deploy_Mock_destination.s.sol))
- `make send-direct-message PROD=true LEDGER=true`: sends a message from ccc ethereum to the specified destination. (Destination network should be updated [here](./scripts/helpers/Send_Direct_CCMessage.s.sol)).
